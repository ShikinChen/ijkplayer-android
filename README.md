# ijkplayer

### 构建环境
- Common
 - Mac OS X 14.3
- Android
 - [NDK r25](https://github.com/android/ndk/wiki/Unsupported-Downloads)
 - Android Studio 2023.1.1 Patch 2
 - Gradle 7.2
 - Xcode 12.5.1
- [HomeBrew](http://brew.sh)
 - ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
 - brew install git


### 构建前配置
```
# install homebrew, git, yasm
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git
brew install yasm

# add these lines to your ~/.bash_profile or ~/.profile
# export ANDROID_SDK=<your sdk path>
# export ANDROID_NDK=<your ndk path>

# on Cygwin (unmaintained)
# install git, make, yasm
```
### 拉取源码
```
git clone https://github.com/ShikinChen/ijkplayer-android --recursive
```

### 构建和导入
```
git clone https://github.com/ShikinChen/ijkplayer-android
cd ijkplayer-android

#编译ffmpeg一定要使用ndk r25
export ANDROID_NDK=NDK r25的路径

cd android/contrib
./compile-ffmpeg.sh arm64

#可选
cd ..
./compile-ijk.sh arm64

#执行完compile-ffmpeg.sh arm64 编译完ffmpeg的arm64动态库后 直接将 ./android/ijkplayer 导入整个项目

```


