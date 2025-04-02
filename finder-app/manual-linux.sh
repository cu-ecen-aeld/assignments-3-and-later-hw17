#!/bin/sh
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-
echo "\e[1;45m --- Running manual-linux.sh --- \e[0m"
if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}
cd "$OUTDIR"

if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    echo "\e[1;43m KERNEL BUILD ------- \e[0m"
    #arch/arm64/configs/defconfig -- directory
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
    echo "\e[1;43m --- finish building --- \e[0m"
    #------------------------------------------------------
fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
echo "\e[1;43m Create necessary base directories \e[0m"
mkdir -v -p "${OUTDIR}/rootfs"
cd "${OUTDIR}/rootfs"
mkdir -v -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -v -p usr/bin usr/lib usr/sbin
mkdir -v -p var/log
#---------------------------------------------------

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "Checkout ${BUSYBOX_VERSION} BUSYBOX version"
    make distclean
    make defconfig
    #-----------------------------------------------
else
    cd busybox
fi

# TODO: Make and install busybox
echo "\e[1;32m Make and install busybox \e[0m"
make distclean
make defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} -j$(nproc)
echo "\e[1;43m INSTALLING BUSYBOX \e[0m"
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} CONFIG_PREFIX=${OUTDIR}/rootfs install

cd "${OUTDIR}/rootfs"
echo "\e[1;43m Library dependencies \e[0m"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
echo "\e[1;43m Add library dependencies to rootfs \e[0m"
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
cp -v ${SYSROOT}/lib/ld-linux-aarch64.so.1 lib
cp -v ${SYSROOT}/lib64/libm.so.6 lib64
cp -v ${SYSROOT}/lib64/libresolv.so.2 lib64
cp -v ${SYSROOT}/lib64/libc.so.6 lib64

# TODO: Make device nodes
echo "\e[1;32m Make device nodes \e[0m"
sudo mknod -m 666 dev/null    c 1 3
sudo mknod -m 600 dev/console c 5 1

# TODO: Clean and build the writer utility
echo "\e[1;32m Clean and build the writer utility \e[0m"
cd "${FINDER_APP_DIR}"
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# TODO: Copy the finder related scripts and executables to the /home directory on the target rootfs
echo "\e[1;32m Copy related files to target rootfs \e[0m"
cp -v writer ${OUTDIR}/rootfs/home
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} clean
cp -v finder.sh finder-test.sh ${OUTDIR}/rootfs/home

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
rsync -v -R conf/username.txt ${OUTDIR}/rootfs/home
rsync -v -R conf/assignment.txt ${OUTDIR}/rootfs/home
cp -v autorun-qemu.sh ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
echo "\e[1;32m chown root directory \e[0m"
cd "${OUTDIR}/rootfs"
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
echo "\e[1;32m Create initframfs.cpio.gz \e[0m"
cd "${OUTDIR}/rootfs"
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd "${OUTDIR}"
gzip -f initramfs.cpio
echo "\e[1;45m --- END --- \e[0m"
exit 0
