# Installation

To install application select file with valid architecture.
You can find it out by executing `adb shell uname -m` command from local computer.

The reply will tell you what architecture the Linux kernel in your Android OS is running. It tells you this in Linux
terminology, rather than Android ABI names:

| Linux kernel                            | Android's ABI |
|-----------------------------------------|---------------|
| `aarch64` - 64-bit ARMv8-A              | `arm64-v8a`   |
| `armv7l` - 32-bit ARMv7-A little-endian | `armeabi-v7a` |
| `x86_64` - 64-bit x86                   | `x86_64`      |

Other values are not supported in relased **APK** version.

> If You have no idea what that means, just use **AAB** file version. 
