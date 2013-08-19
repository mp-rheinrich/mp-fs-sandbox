#!/bin/bash -x

set -e

bindir=`dirname $0`

keyid="03C3951A"

numproc=`cat /proc/cpuinfo |grep -c processor`
[ -z "$numproc" ] && numproc=1
#numproc=$(($numproc * 2))

if test -f ./source3/VERSION; then
   vers=3x
else
   vers=4x
fi

SAMBA_ERRORS_IGNORE="\
grep -v \"Unable to determine origin of type\" | \
grep -v \"is not a pointer or array, skip client functions\" | \
grep -v \"is a pointer to type 'string', skip client functions\""

CONFIGOPTS=
REV="$(git rev-parse HEAD)"
if test x"${vers}" = x3x; then
	# version 3 requires a different setup
	cd source3
	./autogen-waf.sh
	DESTDIR_TMP="../install.tmp"
	OUTDIR="../../out/output/sha1/$REV"
	CONFIGOPTS="--enable-selftest --with-ldap --with-ads --with-krb5"
else
	DESTDIR_TMP="install.tmp"
	OUTDIR="../out/output/sha1/$REV"
fi

OUTDIR_TMP="${OUTDIR}.tmp"

DIST=$(lsb_release -sc)

install -d -m0755 -- "$DESTDIR_TMP"

echo "$0: configuring..."
ionice -c3 nice -n20 ./configure ${CONFIGOPTS}

NCPU=$(( 2 * `grep -c processor /proc/cpuinfo` ))

echo "$0: building..."
echo --START-IGNORE-WARNINGS
# filter out idl errors "Unable to determine origin..." to avoid gitbuilder failing
ionice -c3 nice -n20 make -j$NCPU 2> >( eval ${SAMBA_ERRORS_IGNORE} ) || exit 4

echo "$0: installing..."
ionice -c3 nice -n20 make -j$NCPU install DESTDIR=${DESTDIR_TMP} || exit 4
echo --STOP-IGNORE-WARNINGS


if test x"${vers}" = x3x; then
	SMBVERS=$(./bin/smbd --version | sed -e "s|Version ||")
else
	export LD_LIBRARY_PATH=${DESTDIR_TMP}/usr/local/samba/lib/:${DESTDIR_TMP}/usr/local/samba/lib/private/
	SMBVERS=$(${DESTDIR_TMP}/usr/local/samba/sbin/smbd --version | sed -e "s|Version ||")
fi

fpm -s dir -t deb -n samba -v ${SMBVERS} -C ${DESTDIR_TMP} -d krb5-user usr | \
	 grep -v "already initialized constant COMPRESSION_TYPES"

install -d -m0755 -- "$OUTDIR_TMP"
printf '%s\n' "$REV" >"$OUTDIR_TMP/sha1"
printf '%s\n' "$SMBVERS" >"$OUTDIR_TMP/version"
printf '%s\n' "samba" >"$OUTDIR_TMP/name"

mkdir -p $OUTDIR_TMP/conf
/srv/ceph-build/gen_reprepro_conf.sh $OUTDIR_TMP 03C3951A

GNUPGHOME="/srv/gnupg" reprepro --ask-passphrase -b $OUTDIR_TMP -C main --ignore=undefinedtarget --ignore=wrongdistribution includedeb ${DIST} samba_${SMBVERS}_*.deb

# we're successful, the files are ok to be published; try to be as
# atomic as possible about replacing potentially existing OUTDIR
if [ -e "$OUTDIR" ]; then
    rm -rf -- "$OUTDIR.old"
    mv -- "$OUTDIR" "$OUTDIR.old"
fi
mv -- "$OUTDIR_TMP" "$OUTDIR"
rm -rf -- "$OUTDIR.old"

# rebuild combined debian repo output
(
    cd ../out/output
    rm -rf combined
    GNUPGHOME="/srv/gnupg" /srv/ceph-build/merge_repos.sh combined sha1/*
)

exit 0
