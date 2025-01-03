# ijkplayer

## <mark>为了学习 aosp 已经替换 Ubuntu 主开发系统(主要 mac book pro 太贵),脚本适配 Ubuntu 为主,MacOS 尽量适配</mark>

### <mark>有升级到 FFmpeg 7.1 的分支,因为 7.1 的 api 变化有点大,对源码修改比较大,修改后不知道稳定如何,所以单独开一个分支,需要的请自行切换或者拉取</mark>

```shell
git clone https://github.com/ShikinChen/ijkplayer-android --recursive -b ijk0.8.8--ff7.1
```

### 构建环境

- Common
- Mac OS X 14.3/Ubuntu 22.04
- Android
- [NDK r27](https://github.com/android/ndk/wiki/Unsupported-Downloads)
- Android Studio 2023.1.1 Patch 2
- Gradle 7.2
- Xcode 12.5.1
- Python 3.9.x
- [HomeBrew](http://brew.sh)
- ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
- brew install git

### 构建前配置

#### MacOS

```shell
# install homebrew, git, yasm
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm
brew install pyenv
```

配置 pyenv

```shell
#编辑环境变量文件
vim ~/.bash_profile
#追加下面内容
export PYENV_ROOT=/usr/local/var/pyenv
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi
eval "$(pyenv init --path)"
```

#### Ubuntu

```shell
# 将Shell的解释器改为dash,执行dpkg-reconfigure dash命令，然后选择no
sudo dpkg-reconfigure dash
sudo apt install -y ninja-build git
curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
```

配置 pyenv

```shell
#编辑环境变量文件
vim ~/.bashrc
#追加下面内容
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

#### 安装 python 3.9.19

```shell
pyenv install 3.9.19
```

终端环境变量配置

```shell
# add these lines to your ~/.bash_profile or ~/.profile
# export ANDROID_SDK=<your sdk path>
# export ANDROID_NDK=<your ndk path>

```

### 拉取源码

```shell
git clone https://github.com/ShikinChen/ijkplayer-android --recursive
```

如果拉取部分模块出错,需要重新拉取项目模块

```shell
cd ijkplayer-android
git submodule update --init --remote --recursive --progress
```

#### 如果需要 openssl,执行下面脚本拉取 openssl,后面会自动进行链接到 FFmpeg(可选)

<mark>在 MacOS 的 ndk 27 以下没办法进行 ld 引入 ssl 和 crypto 库,导致在 FFmpeg 编译的检测时候出现错误,而 ndk 27 是没办法编译 armv7a 版本,如果需要编译 armv7a 版本需要在 Ubuntu 进行</mark>

```shell
cd ijkplayer-android
./init-android-openssl.sh
```

### 构建和导入

```shell
cd ijkplayer-android

#编译ffmpeg一定要使用ndk r27
export ANDROID_NDK=NDK r27的路径
#ndk r27已经不支持armeabi-v7a
cd android/contrib
./compile-ffmpeg.sh arm64
```

执行完 compile-ffmpeg.sh arm64 编译完 ffmpeg 的 arm64 静态库后,用 android studio 直接将
ijkplayer-android/android/ijkplayer/android/ijkplayer 导入整个项目,并且在设置修改 Gradle JDK 为
java-11

### 打包

#### 基于 ndk r27 打包 arm64-v8a 版本(项目默认是 ndk r27)

执行之前一样要定义 ANDROID_NDK 环境变量,并且 ffmpeg 已经编译好

```shell
export ANDROID_NDK=NDK r27的路径
```

```shell
cd ijkplayer-android/android/ijkplayer
./gradlew :ijkplayer-java:assembleRelease
```

最后生成的 ijkplayer-java-release.aar 在
ijkplayer-android/android/ijkplayer/ijkplayer-java/build/outputs/aar/目录下

#### 基于 ndk r21 打包 armeabi-v7a 和 arm64-v8a 版本

```shell
export ANDROID_NDK=NDK r21的路径
```

然后修改 ijkplayer-android/android/ijkplayer/ijkplayer-java/build.gradle 的 ndk 和 ndkVersion,如果需要运行
ijkplayer-example 项目也一样修改它的 build.gradle 的 ndk 和 ndkVersion

```gradle
ndk {
    abiFilters 'armeabi-v7a', 'arm64-v8a'
}
```

```gradle
 ndkVersion '21.4.7075529'
```

重新进行 ffmpeg 编译的 armv7a 和 arm64

```shell
cd ijkplayer-android
cd android/contrib
./compile-ffmpeg.sh armv7a
./compile-ffmpeg.sh arm64
```

打包 aar

```shell
cd ../..
cd android/ijkplayer
./gradlew :ijkplayer-java:assembleRelease
```
