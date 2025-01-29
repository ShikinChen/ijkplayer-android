#! /usr/bin/env bash
#
# Copyright (C) 2013-2014 Zhang Rui <bbcallen@gmail.com>
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

# This script is based on projects below
# https://github.com/yixia/FFmpeg-Android
# http://git.videolan.org/?p=vlc-ports/android.git;a=summary

#--------------------
echo "===================="
echo "[*] check env $1"
echo "===================="
set -e

#--------------------
# common defines
FF_ARCH=$1
FF_BUILD_OPT=$2
echo "FF_ARCH=$FF_ARCH"
echo "FF_BUILD_OPT=$FF_BUILD_OPT"
if [ -z "$FF_ARCH" ]; then
    echo "You must specific an architecture 'armv7a, x86, ...'."
    echo ""
    exit 1
fi

CURRENT_DIR=$(dirname "$(readlink -f "$0")")
FF_BUILD_ROOT=$(dirname "$CURRENT_DIR")
FF_ANDROID_PLATFORM=21

FF_BUILD_NAME=
FF_SOURCE=
FF_CROSS_PREFIX=
FF_DEP_OPENSSL_INC=
FF_DEP_OPENSSL_LIB=

FF_DEP_LIBSOXR_INC=
FF_DEP_LIBSOXR_LIB=

FF_CFG_FLAGS=

FF_EXTRA_CFLAGS="-D__ANDROID_API__=$FF_ANDROID_PLATFORM"
FF_EXTRA_LDFLAGS=
FF_DEP_LIBS=

FF_MODULE_DIRS="compat libavcodec libavfilter libavformat libavutil libswresample libswscale"
FF_ASSEMBLER_SUB_DIRS=

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
    FF_BUILD_NAME=ffmpeg-armv7a
    FF_BUILD_NAME_OPENSSL=openssl-armv7a
    FF_BUILD_NAME_LIBSOXR=libsoxr-armv7a
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=arm-linux-androideabi
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=arm --cpu=cortex-a8"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-neon"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-thumb"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=armv7-a -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb -fno-integrated-as"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS -Wl,--fix-cortex-a8"

    FF_ASSEMBLER_SUB_DIRS="arm"

elif [ "$FF_ARCH" = "x86" ]; then
    FF_BUILD_NAME=ffmpeg-x86
    FF_BUILD_NAME_OPENSSL=openssl-x86
    FF_BUILD_NAME_LIBSOXR=libsoxr-x86
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=i686-linux-android
    FF_TOOLCHAIN_NAME=x86-${FF_GCC_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=x86 --cpu=i686"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS -march=atom -msse3 -ffast-math -mfpmath=sse"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"

    FF_ASSEMBLER_SUB_DIRS="x86"

elif [ "$FF_ARCH" = "x86_64" ]; then
    FF_BUILD_NAME=ffmpeg-x86_64
    FF_BUILD_NAME_OPENSSL=openssl-x86_64
    FF_BUILD_NAME_LIBSOXR=libsoxr-x86_64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=x86_64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=x86_64 --disable-neon --disable-asm --disable-x86asm --disable-mmx --disable-mmxext --disable-sse"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"

    FF_ASSEMBLER_SUB_DIRS="x86_64"

elif [ "$FF_ARCH" = "arm64" ]; then
    FF_BUILD_NAME=ffmpeg-arm64
    FF_BUILD_NAME_OPENSSL=openssl-arm64
    FF_BUILD_NAME_LIBSOXR=libsoxr-arm64
    FF_SOURCE=$FF_BUILD_ROOT/$FF_BUILD_NAME

    FF_CROSS_PREFIX=aarch64-linux-android
    FF_TOOLCHAIN_NAME=${FF_CROSS_PREFIX}-${FF_GCC_64_VER}

    FF_CFG_FLAGS="$FF_CFG_FLAGS --arch=aarch64 --enable-neon"

    FF_EXTRA_CFLAGS="$FF_EXTRA_CFLAGS"
    FF_EXTRA_LDFLAGS="$FF_EXTRA_LDFLAGS"

    FF_ASSEMBLER_SUB_DIRS="aarch64"
else
    echo "unknown architecture $FF_ARCH"
    exit 1
fi

FF_SOURCE=$FF_BUILD_ROOT/../../extra/ffmpeg

if [ ! -d $FF_SOURCE ]; then
    echo ""
    echo "!! ERROR"
    echo "!! Can not find FFmpeg directory for $FF_BUILD_NAME"
    echo "!! Run 'sh init-android.sh' first"
    echo ""
    exit 1
fi

FF_TOOLCHAIN_PATH=$FF_BUILD_ROOT/build/toolchain-$FF_ARCH
FF_MAKE_TOOLCHAIN_FLAGS="$FF_MAKE_TOOLCHAIN_FLAGS --install-dir=$FF_TOOLCHAIN_PATH"

FF_SYSROOT=$FF_TOOLCHAIN_PATH/sysroot
FF_PREFIX=$FF_BUILD_ROOT/build/$FF_BUILD_NAME/output

FF_DEP_OPENSSL_INC=$FF_BUILD_ROOT/build/$FF_BUILD_NAME_OPENSSL/output/include
FF_DEP_OPENSSL_LIB=$FF_BUILD_ROOT/build/$FF_BUILD_NAME_OPENSSL/output/lib
FF_DEP_LIBSOXR_INC=$FF_BUILD_ROOT/build/$FF_BUILD_NAME_LIBSOXR/output/include
FF_DEP_LIBSOXR_LIB=$FF_BUILD_ROOT/build/$FF_BUILD_NAME_LIBSOXR/output/lib

case "$UNAME_S" in
CYGWIN_NT-*)
    FF_SYSROOT="$(cygpath -am $FF_SYSROOT)"
    FF_PREFIX="$(cygpath -am $FF_PREFIX)"
    ;;
esac
if [ -d "$FF_PREFIX" ]; then
    rm -rf $FF_PREFIX
fi
mkdir -p $FF_PREFIX
# mkdir -p $FF_SYSROOT

FF_TOOLCHAIN_TOUCH="$FF_TOOLCHAIN_PATH/$IJK_NDK_REL"
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
fi

#--------------------
echo ""
echo "--------------------"
echo "[*] check ffmpeg env"
echo "--------------------"
FF_TOOLCHAIN_PATH_BIN=$FF_TOOLCHAIN_PATH/bin
export PATH=$FF_TOOLCHAIN_PATH_BIN:$PATH

NDK_MAJOR=$(echo "$IJK_NDK_REL" | cut -d'.' -f1)
if [ "$NDK_MAJOR" -lt 22 ]; then
    export LD=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-ld
else
    export LD=${FF_TOOLCHAIN_PATH_BIN}/ld
fi

export CC=${FF_TOOLCHAIN_PATH_BIN}/${FF_CROSS_PREFIX}-${FF_CC}
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

FF_CFLAGS="-O3 -Wall -pipe \
    -std=c99 \
    -ffast-math \
    -fstrict-aliasing -Werror=strict-aliasing \
    -Wno-psabi -Wa,--noexecstack \
    -DANDROID -DNDEBUG"

# cause av_strlcpy crash with gcc4.7, gcc4.8
# -fmodulo-sched -fmodulo-sched-allow-regmoves

# --enable-thumb is OK
#FF_CFLAGS="$FF_CFLAGS -mthumb"

# not necessary
#FF_CFLAGS="$FF_CFLAGS -finline-limit=300"

export COMMON_FF_CFG_FLAGS=
source $FF_BUILD_ROOT/../../config/module.sh

#--------------------
# with openssl

OPENSSL_SOURCE=$FF_BUILD_ROOT/../../extra/openssl

export CFLAGS=""
export CPPFLAGS=""
export LDFLAGS=""

if [ -d $OPENSSL_SOURCE ]; then
    $CURRENT_DIR/../compile-openssl.sh $FF_ARCH
fi

if [ -f "${FF_DEP_OPENSSL_LIB}/libssl.a" ]; then
    echo "OpenSSL detected"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-nonfree"
    # FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-version3"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-openssl"

    FF_CFLAGS="$FF_CFLAGS -I${FF_DEP_OPENSSL_INC} "
    FF_DEP_LIBS="$FF_DEP_LIBS -lssl -lcrypto"

    export CPPFLAGS="-I${FF_DEP_OPENSSL_INC}"
    export LDFLAGS="-L${FF_DEP_OPENSSL_LIB} -lssl -lcrypto -v"
fi

if [ -f "${FF_DEP_LIBSOXR_LIB}/libsoxr.a" ]; then
    echo "libsoxr detected"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-libsoxr"

    FF_CFLAGS="$FF_CFLAGS -I${FF_DEP_LIBSOXR_INC}"
    FF_DEP_LIBS="$FF_DEP_LIBS -L${FF_DEP_LIBSOXR_LIB} -lsoxr"
fi

FF_CFG_FLAGS="$FF_CFG_FLAGS $COMMON_FF_CFG_FLAGS"

#--------------------
# Standard options:
FF_CFG_FLAGS="$FF_CFG_FLAGS --prefix=$FF_PREFIX"

# Advanced options (experts only):
FF_CFG_FLAGS="$FF_CFG_FLAGS --cross-prefix=${FF_CROSS_PREFIX}-"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-cross-compile"
FF_CFG_FLAGS="$FF_CFG_FLAGS --target-os=android"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-pic"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-pthreads"
FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-vulkan"
FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-shared"
FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-static"
FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-doc"
FF_CFG_FLAGS="$FF_CFG_FLAGS --sysroot=$FF_SYSROOT"

# FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-symver"

if [ "$FF_ARCH" = "x86" ]; then
    FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-asm"
else
    # Optimization options (experts only):
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-asm"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-inline-asm"
fi

case "$FF_BUILD_OPT" in
debug)
    FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-optimizations"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-debug"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --disable-small"
    ;;
*)
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-optimizations"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-debug"
    FF_CFG_FLAGS="$FF_CFG_FLAGS --enable-small"
    ;;
esac

FF_EXTRA_LDFLAGS="-lm $FF_EXTRA_LDFLAGS"

#--------------------
echo ""
echo "--------------------"
echo "[*] configurate ffmpeg"
echo "--------------------"
cd $FF_SOURCE
if [ -f "./config.h" ]; then
    echo clean $(pwd)/config.h
    make distclean
fi
which $CC
./configure $FF_CFG_FLAGS \
    --extra-cflags="$FF_CFLAGS $FF_EXTRA_CFLAGS" \
    --extra-ldflags="$FF_EXTRA_LDFLAGS $FF_DEP_LIBS"
# make clean

# --------------------
echo ""
echo "--------------------"
echo "[*] compile ffmpeg"
echo "--------------------"
cp config.* $FF_PREFIX
make $FF_MAKE_FLAGS >/dev/null
make install
mkdir -p $FF_PREFIX/include/libffmpeg
cp -f config.h $FF_PREFIX/include/libffmpeg/config.h
