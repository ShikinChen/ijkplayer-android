# ijkplayer

## <mark>为了学习 aosp 已经替换 Ubuntu 主开发系统(主要 mac book pro 太贵),脚本适配 Ubuntu 为主,MacOS 尽量适配</mark>

### 构建环境

- Common
- Mac OS X 14.3/Ubuntu 22.04
- Android
- [NDK r27](https://github.com/android/ndk/wiki/Unsupported-Downloads)
- Android Studio 2023.1.1 Patch 2
- Gradle 7.2
- Xcode 12.5.1
- [HomeBrew](http://brew.sh)
- ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
- brew install git

### 构建前配置

MacOS

```shell
# install homebrew, git, yasm
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm
```

Ubuntu

```shell
# 将Shell的解释器改为dash,执行dpkg-reconfigure dash命令，然后选择no
sudo dpkg-reconfigure dash
sudo apt install -y ninja-build git
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

### 构建和导入

```shell
cd ijkplayer-android

#编译ffmpeg一定要使用ndk r27
export ANDROID_NDK=NDK r27的路径
#ndk r27已经不支持armeabi-v7a
cd android/contrib
./compile-ffmpeg.sh arm64

```

执行完 compile-ffmpeg.sh arm64 编译完 ffmpeg 的 arm64 静态库后,用android studio 直接将 ijkplayer-android/android/ijkplayer/android/ijkplayer 导入整个项目,并且在设置修改 Gradle JDK 为 java-11

### 打包

执行之前一样要定义 ANDROID_NDK 环境变量,并且 ffmpeg 已经编译好

```shell
export ANDROID_NDK=NDK r27的路径
```

```shell
cd ijkplayer-android/android/ijkplayer
./gradlew :ijkplayer-java:assembleRelease
```

最后生成的 ijkplayer-java-release.aar 在 ijkplayer-android/android/ijkplayer/ijkplayer-java/build/outputs/aar/目录下
