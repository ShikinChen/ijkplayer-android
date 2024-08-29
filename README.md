# ijkplayer 

## <mark>为了学习aosp已经替换Ubuntu主开发系统(主要mac book pro太贵),脚本适配Ubuntu为主,MacOS尽量适配</mark>

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
```
# install homebrew, git, yasm
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm
```
Ubuntu
```
# 将Shell的解释器改为dash,执行dpkg-reconfigure dash命令，然后选择no
sudo dpkg-reconfigure dash
sudo apt install -y ninja-build git
```

终端环境变量配置
```
# add these lines to your ~/.bash_profile or ~/.profile
# export ANDROID_SDK=<your sdk path>
# export ANDROID_NDK=<your ndk path>

```
### 拉取源码
```
git clone https://github.com/ShikinChen/ijkplayer-android --recursive
```
如果拉取部分模块出错,需要重新拉取项目模块
```
cd ijkplayer-android
git submodule update --init --remote --recursive --progress
```

### 构建和导入
```
cd ijkplayer-android

#编译ffmpeg一定要使用ndk r27
export ANDROID_NDK=NDK r27的路径

cd android/contrib
./compile-ffmpeg.sh arm64

```
执行完compile-ffmpeg.sh arm64 编译完ffmpeg的arm64动态库后 直接将 ./android/ijkplayer 导入整个项目


