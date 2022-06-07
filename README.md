# ijkplayer

### My Build Environment
- Common
 - Mac OS X 11.3
- Android
 - [NDK r10e](http://developer.android.com/tools/sdk/ndk/index.html)
 - Android Studio 2020.3.1
 - Gradle 6.5
 - Xcode 12.5.1
- [HomeBrew](http://brew.sh)
 - ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
 - brew install git


### Before Build
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

### Build Android
```
git clone https://github.com/ShikinChen/ijkplayer-android
cd ijkplayer-android

./init-android.sh

#编译ffmpeg一定要使用ndk r17
export ANDROID_NDK=NDK r17的路径

cd android/contrib
./compile-ffmpeg.sh clean
./compile-ffmpeg.sh arm64

//会报 tools/do-compile-ffmpeg.sh: line 317: 40808 Segmentation fault: 11  make $FF_MAKE_FLAGS > /dev/null 错误再执行一次
./compile-ffmpeg.sh arm64

cd ..
./compile-ijk.sh arm64

#执行完compile-ffmpeg.sh arm64 编译完ffmpeg的arm64动态库后 直接将 ./android/ijkplayer 导入整个项目

```


