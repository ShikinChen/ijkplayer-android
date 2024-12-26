#! /usr/bin/env bash
#
# Copyright (C) 2014 Miguel Botón <waninkoko@gmail.com>
# Copyright (C) 2014 Zhang Rui <bbcallen@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#--------------------
set -e

if [ -z "$ANDROID_NDK" ]; then
    echo "You must define ANDROID_NDK before starting."
    echo "They must point to your NDK directories.\n"
    exit 1
fi

#--------------------
# common defines
FF_ARCH=$1
if [ -z "$FF_ARCH" ]; then
    echo "You must specific an architecture 'armv7a, x86, ...'.\n"
    exit 1
fi

CURRENT_DIR=$(dirname "$(readlink -f "$0")")
FF_BUILD_ROOT=$(dirname "$CURRENT_DIR")
FF_ANDROID_PLATFORM=21

FF_BUILD_NAME=
FF_SOURCE=
FF_CROSS_PREFIX=

FF_CFG_FLAGS=
FF_PLATFORM_CFG_FLAGS=

FF_EXTRA_CFLAGS=
FF_EXTRA_LDFLAGS=

#--------------------
echo ""
echo "--------------------"
echo "[*] make NDK standalone toolchain"
echo "--------------------"
source $CURRENT_DIR/do-detect-env.sh
FF_MAKE_TOOLCHAIN_FLAGS=$IJK_MAKE_TOOLCHAIN_FLAGS
FF_MAKE_FLAGS=$IJK_MAKE_FLAG
FF_GCC_VER=$IJK_GCC_VER
FF_GCC_64_VER=$IJK_GCC_64_VER
FF_CC=$IJK_CC
FF_IS_NOT_SUPPORT_ARM=$IJK_IS_NOT_SUPPORT_ARM

if $FF_IS_NOT_SUPPORT_ARM && [ "$FF_ARCH" = "armv7a" ]; then
    echo "ndk ${IJK_NDK_REL} not support armv7a"
    exit 1
fi

#----- armv7a begin -----
if [ "$FF_ARCH" = "armv7a" ]; then
    FF_BUILD_NAME=openssl-armv7a
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=arm-linux-androideabi
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_VER}

    FF_PLATFORM_CFG_FLAGS="android-arm"

    FF_CFG_FLAGS="$FF_CFG_FLAGS -DOPENSSL_NO_ATEXIT"
    FF_CFG_FLAGS="$FF_CFG_FLAGS -nostartfiles"

elif [ "$FF_ARCH" = "x86" ]; then
    FF_BUILD_NAME=openssl-x86
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=i686-linux-android
    FF_TOOLCHAIN_NAME=x86-${FF_GCC_VER}

    FF_PLATFORM_CFG_FLAGS="android-x86"

    FF_CFG_FLAGS="$FF_CFG_FLAGS no-asm"

elif [ "$FF_ARCH" = "x86_64" ]; then

    FF_BUILD_NAME=openssl-x86_64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=x86_64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    FF_PLATFORM_CFG_FLAGS="linux-x86_64"

elif [ "$FF_ARCH" = "arm64" ]; then

    FF_BUILD_NAME=openssl-arm64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=aarch64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    FF_PLATFORM_CFG_FLAGS="linux-aarch64"

else
    echo "unknown architecture $FF_ARCH"
    exit 1
fi

FF_SOURCE=$FF_BUILD_ROOT/../../extra/openssl

if [ ! -d $FF_SOURCE ]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find openssl directory for $FF_BUILD_NAME"
    echo "!! Run 'sh init-android.sh' first"
    echo ""
    exit 1
fi

FF_TOOLCHAIN_PATH=$FF_BUILD_ROOT/build/toolchain-$FF_ARCH
FF_MAKE_TOOLCHAIN_FLAGS="$FF_MAKE_TOOLCHAIN_FLAGS --install-dir=$FF_TOOLCHAIN_PATH"

FF_SYSROOT=$FF_TOOLCHAIN_PATH/sysroot
FF_PREFIX=$FF_BUILD_ROOT/build/$FF_BUILD_NAME/output

if [ -d "$FF_PREFIX" ]; then
    rm -rf $FF_PREFIX
fi
mkdir -p $FF_PREFIX

FF_TOOLCHAIN_TOUCH="$FF_TOOLCHAIN_PATH/$IJK_NDK_REL"

FF_TOOLCHAIN_PATH_BIN=$FF_TOOLCHAIN_PATH/bin
export PATH=$FF_TOOLCHAIN_PATH_BIN:$PATH

if [ ! -f "$FF_TOOLCHAIN_TOUCH" ]; then
    if [ -d "$FF_TOOLCHAIN_PATH" ]; then
        rm -rf $FF_TOOLCHAIN_PATH
    fi
    if [ "$FF_CC" = "gcc" ]; then
        if [ ! -f "$FF_TOOLCHAIN_TOUCH" ]; then
            $ANDROID_NDK/build/tools/make-standalone-toolchain.sh \
                $FF_MAKE_TOOLCHAIN_FLAGS \
                --platform=android-$FF_ANDROID_PLATFORM \
                --toolchain=$FF_TOOLCHAIN_NAME
        fi
    else
        ARCH=$FF_ARCH
        if [ "$FF_ARCH" = "armv7a" ]; then
            ARCH=arm
        fi
        FF_MAKE_TOOLCHAIN_FLAGS="--install-dir $FF_TOOLCHAIN_PATH --arch $ARCH --api $FF_ANDROID_PLATFORM"
        python3 $ANDROID_NDK/build/tools/make_standalone_toolchain.py \
            $FF_MAKE_TOOLCHAIN_FLAGS
    fi
    touch $FF_TOOLCHAIN_TOUCH
    cd $FF_TOOLCHAIN_PATH_BIN && ln -s ${FF_CROSS_PREFIX}-ld ld
    cd -
fi

FF_LD=${FF_TOOLCHAIN_PATH_BIN}/ld
echo FF_LD:${FF_LD}
if [[ ! -f "$FF_LD" ]]; then
    if [[ ! -L "$FF_LD" ]]; then
        cd $FF_TOOLCHAIN_PATH_BIN && ln -s ${FF_CROSS_PREFIX}-ld ld
        cd -
    fi
fi

# mkdir -p $FF_SYSROOT

if [ "$FF_ARCH" = "armv7a" ]; then
    FF_LDFG_FLAGS="-L${FF_TOOLCHAIN_PATH}/lib/gcc/${FF_CROSS_PREFIX}/4.9.x/armv7-a"
    SYSROOT_LIBS=${FF_TOOLCHAIN_PATH}/sysroot/usr/lib/${FF_CROSS_PREFIX}/${FF_ANDROID_PLATFORM}
    FF_LDFG_FLAGS="$FF_LDFG_FLAGS -L${SYSROOT_LIBS}"
fi

FF_MAKE_TOOLCHAIN_FLAGS=$IJK_MAKE_TOOLCHAIN_FLAGS
FF_MAKE_FLAGS=$IJK_MAKE_FLAG

#--------------------
echo ""
echo "--------------------"
echo "[*] check openssl env"
echo "--------------------"

export CC=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-${FF_CC}
export LD=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-ld
export AR=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-ar
export STRIP=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-strip

NM=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-nm
RANLIB=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-ranlib

if [ ! -f "$AR" ]; then
    ln -s ${FF_TOOLCHAIN_PATH_BIN}/llvm-ar $AR
fi
if [ ! -f "$STRIP" ]; then
    ln -s ${FF_TOOLCHAIN_PATH_BIN}/llvm-strip $STRIP
fi
if [ ! -f "$NM" ]; then
    ln -s ${FF_TOOLCHAIN_PATH_BIN}/llvm-nm $NM
fi
if [ ! -f "$RANLIB" ]; then
    ln -s ${FF_TOOLCHAIN_PATH_BIN}/llvm-ranlib $RANLIB
fi

#--------------------
# Standard options:
SYSROOT=${FF_TOOLCHAIN_PATH}/sysroot

FF_CFG_FLAGS="$FF_CFG_FLAGS zlib-dynamic"
FF_CFG_FLAGS="$FF_CFG_FLAGS no-shared"
FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$FF_PREFIX"
FF_CFG_FLAGS="$FF_CFG_FLAGS --sysroot=${SYSROOT}"
# FF_CFG_FLAGS="$FF_CFG_FLAGS --cross-compile-prefix=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-"
FF_CFG_FLAGS="$FF_CFG_FLAGS $FF_PLATFORM_CFG_FLAGS"
# FF_CFG_FLAGS="$FF_CFG_FLAGS CC=$FF_CC"
FF_CFG_FLAGS="$FF_CFG_FLAGS -D__ANDROID_API__=$FF_ANDROID_PLATFORM"

#--------------------
echo ""
echo "--------------------"
echo "[*] configurate openssl"
echo "--------------------"
cd $FF_SOURCE

if [ -f "./Makefile" ]; then
    echo clean $(pwd)/Makefile
    make distclean
fi
which $CC
echo "./Configure $FF_CFG_FLAGS"
./Configure $FF_CFG_FLAGS $FF_LDFG_FLAGS

#--------------------
echo ""
echo "--------------------"
echo "[*] compile openssl"
echo "--------------------"
make depend
make $FF_MAKE_FLAGS
make install_sw

#--------------------
echo ""
echo "--------------------"
echo "[*] link openssl"
echo "--------------------"
