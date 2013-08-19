#!/bin/bash -x

set -e

if test -f ./source3/VERSION; then
   vers=3x
else
   vers=4x
fi

SAMBA_ERRORS_IGNORE="\
grep -v \"Unable to determine origin of type\" | \
grep -v \"is not a pointer or array, skip client functions\" | \
grep -v \"is a pointer to type 'string', skip client functions\""

CONFIGOPTS="--enable-selftest --with-ldap --with-ads"
REV="$(git rev-parse HEAD)"
if test x"${vers}" = x3x; then
	# version 3 requires a different setup
	cd source3
	./autogen-waf.sh
	DESTDIR_TMP="../install.tmp"
	OUTDIR="../../out/output/sha1/$REV"
	CONFIGOPTS="${CONFIGOPTS} --with-krb5"
else
	DESTDIR_TMP="install.tmp"
	OUTDIR="../out/output/sha1/$REV"
fi


install -d -m0755 -- "$DESTDIR_TMP"

echo "$0: configuring..."
ionice -c3 nice -n20 ./configure ${CONFIGOPTS}

NCPU=$(( 2 * `grep -c processor /proc/cpuinfo` ))

echo "$0: building..."
echo --START-IGNORE-WARNINGS
# filter out idl errors "Unable to determine origin..." to avoid gitbuilder failing
ionice -c3 nice -n20 make -j$NCPU 2> >( eval ${SAMBA_ERRORS_IGNORE} ) || exit 4

REV="$(git rev-parse HEAD)"
OUTDIR="../out/output/sha1/$REV"
OUTDIR_TMP="${OUTDIR}.tmp"
install -d -m0755 -- "$OUTDIR_TMP"
printf '%s\n' "$REV" >"$OUTDIR_TMP/sha1"
MACH="$(uname -m)"
INSTDIR="inst.tmp"
[ ! -e "$INSTDIR" ]
echo "$0: installing..."
ionice -c3 nice -n20 make -j$NCPU install DESTDIR=${PWD}/${INSTDIR} || exit 4
echo --STOP-IGNORE-WARNINGS

if test x"${vers}" = x3x; then
	SMBVERS=$(./bin/smbd --version | sed -e "s|Version ||")
else
	export LD_LIBRARY_PATH=${DESTDIR_TMP}/usr/local/samba/lib/:${DESTDIR_TMP}/usr/local/samba/lib/private/
	SMBVERS=$(${DESTDIR_TMP}/usr/local/samba/sbin/smbd --version | sed -e "s|Version ||")
fi

tar czf "$OUTDIR_TMP/samba-${SMBVERS}.tgz" -C "${INSTDIR}" .
rm -rf -- "${INSTDIR}"

# put our temp files inside .git/ so ls-files doesn't see them
git ls-files --modified >.git/modified-files
if [ -s .git/modified-files ]; then
    rm -rf "$OUTDIR_TMP"
    echo "error: Modified files:" 1>&2
    cat .git/modified-files 1>&2
    exit 6
fi

git ls-files --exclude-standard --others >.git/added-files
if [ -s .git/added-files ]; then
    rm -rf "$OUTDIR_TMP"
    echo "error: Added files:" 1>&2
    cat .git/added-files 1>&2
    exit 7
fi

# we're successful, the files are ok to be published; try to be as
# atomic as possible about replacing potentially existing OUTDIR
if [ -e "$OUTDIR" ]; then
    rm -rf -- "$OUTDIR.old"
    mv -- "$OUTDIR" "$OUTDIR.old"
fi
mv -- "$OUTDIR_TMP" "$OUTDIR"
rm -rf -- "$OUTDIR.old"

exit 0
