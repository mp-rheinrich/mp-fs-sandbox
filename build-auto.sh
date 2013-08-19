#!/bin/sh -x

mydir='/srv/autobuild-ceph'

if ! hostname | grep -q ^gitbuilder- ; then
    echo "hostname "`hostname`"does not make sense to me; i fail"
    exit 1
fi

if hostname | grep -q -- -notcmalloc ; then
    echo "hostname has -notcmalloc, will build --without-tcmalloc"
    export CEPH_EXTRA_CONFIGURE_ARGS="$CEPH_EXTRA_CONFIGURE_ARGS --without-tcmalloc"
fi
if hostname | grep -q -- -gcov ; then
    echo "hostname has -gcov, will --enable-coverage"
    export CEPH_EXTRA_CONFIGURE_ARGS="$CEPH_EXTRA_CONFIGURE_ARGS --enable-coverage"
fi

if hostname | grep -q -- -deb- ; then
    exec $mydir/build-ceph-deb-native.sh
fi
if hostname | grep -q -- -rpm- ; then
    exec $mydir/build-ceph-rpm.sh
fi
if hostname | grep -q -- -tarball- ; then
    exec $mydir/build-ceph.sh
fi

hostname | sed -e "s|gitbuilder-\([^-]*\)-\([^-]*\)-.*$|\1 \2|" | while read -r builder type; do
    if test -f $mydir/build-${builder}-${type}.sh; then
        exec $mydir/build-${builder}-${type}.sh
    fi
done

echo "i don't know what to do with hostname "`hostname`
exit 1

