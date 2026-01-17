# libtorrent4j-16kb-android

**16KB Page Size Compliant libtorrent4j for Android**

Vendored FrostWire **jlibtorrent** sources + build scripts to produce **16KB page-size aligned** Android native libraries for Google Play Store compliance (Android 15+ requirement starting November 1, 2025).

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🎯 Problem

Starting **November 1, 2025**, Google Play requires all apps targeting Android 15 (API 35+) to support 16KB page sizes. Apps using native libraries (`.so` files) that aren't properly aligned will fail Play Store submission with errors like:

```
Your app must support 16 KB memory page sizes by November 1, 2025
```

The standard libtorrent4j libraries available on Maven/JitPack are compiled with 4KB page alignment and will cause this error.

## ✅ Solution

This repository provides a build setup that compiles libtorrent/jlibtorrent with 16KB alignment using linker flags:

- `-Wl,-z,max-page-size=16384`
- `-Wl,-z,common-page-size=16384`

## 📦 What's Included

- **Vendored FrostWire jlibtorrent sources** under `third_party/frostwire-jlibtorrent/`
- **Android build scripts** under `third_party/frostwire-jlibtorrent/swig/`
  - `build-android-arm64.sh`
  - `build-android-arm.sh`
  - (x86 scripts exist but are not required for most apps)

**Built with:** Android NDK r29 (unified LLVM toolchain), 16KB ELF alignment

## 🚀 Usage

### Option 1: Direct JAR Integration (Recommended)

1. **Download the JARs** from the [releases page](../../releases) or clone this repo

2. **Copy to your project:**
   ```bash
   mkdir -p app/libs
   cp libs/*.jar app/libs/
   ```

3. **Update your `app/build.gradle`:**
   ```gradle
   dependencies {
       // Add all JARs from libs folder
       implementation fileTree(dir: 'libs', include: ['*.jar'])
       
       // If using TorrentStream-Android, exclude its bundled libtorrent
       implementation('com.github.TorrentStream:TorrentStream-Android:2.7.0') {
           exclude group: 'com.frostwire.jlibtorrent'
       }
   }
   ```

4. **Ensure proper packaging in `app/build.gradle`:**
   ```gradle
   android {
       packagingOptions {
           jniLibs {
               useLegacyPackaging = false
               keepDebugSymbols += ['**/*.so']
           }
       }
   }
   ```

5. **Build and test:**
   ```bash
   ./gradlew bundleRelease
   ```

### Option 2: Using with TorrentStream-Android

If you're using the TorrentStream-Android wrapper library:

```gradle
dependencies {
    // 16KB-compliant libtorrent4j
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    
    // TorrentStream-Android (will use our 16KB libraries)
    implementation('com.github.TorrentStream:TorrentStream-Android:2.7.0') {
        exclude group: 'com.frostwire.jlibtorrent', module: 'jlibtorrent'
        exclude group: 'com.frostwire.jlibtorrent', module: 'jlibtorrent-android-arm'
        exclude group: 'com.frostwire.jlibtorrent', module: 'jlibtorrent-android-x86'
    }
}
```

### Option 3: Direct libtorrent4j Usage

If you want to use libtorrent4j directly without TorrentStream-Android:

```java
import org.libtorrent4j.*;

// Create session
SessionManager sessionManager = new SessionManager();
sessionManager.start();

// Download torrent
String magnetUri = "magnet:?xt=urn:btih:...";
File saveDir = new File(getExternalFilesDir(null), "torrents");
sessionManager.download(magnetUri, saveDir);

// Listen for alerts
sessionManager.addListener(new AlertListener() {
    @Override
    public int[] types() {
        return null; // All alert types
    }

    @Override
    public void alert(Alert<?> alert) {
        if (alert instanceof TorrentFinishedAlert) {
            // Download complete
        }
    }
});
```

## 🔍 Verification

To verify the libraries are properly aligned, use Android Studio's APK Analyzer:

1. Build → Analyze APK
2. Open your APK/AAB
3. Navigate to `lib/` folder
4. Check the **Alignment** column - should show no warnings

Or use command line:
```bash
# Extract .so file from JAR
unzip -j libtorrent4j-android-arm64-v8a-16kb.jar lib/arm64-v8a/libtorrent4j.so

# Check alignment (requires readelf)
readelf -l libtorrent4j.so | grep LOAD
# Look for Align: 0x4000 (16KB in hex)
```

## 🛠️ Building from Source

If you want to build the 16KB-aligned native libraries yourself:

1. **Build arm64-v8a:**
   ```bash
   cd third_party/frostwire-jlibtorrent/swig
   NON_INTERACTIVE=1 bash ./build-android-arm64.sh
   ```

2. **Build armeabi-v7a:**
   ```bash
   cd third_party/frostwire-jlibtorrent/swig
   NON_INTERACTIVE=1 bash ./build-android-arm.sh
   ```

3. **Outputs:**
   - The build script copies the resulting `libjlibtorrent.so` to:
     - `third_party/frostwire-jlibtorrent/libjlibtorrent.so`

## 📋 Requirements

- **Minimum Android SDK:** 23 (Android 6.0)
- **Target Android SDK:** 35+ (for Play Store compliance)
- **Android Gradle Plugin:** 8.5.1+ (for automatic 16KB alignment)
- **Gradle:** 8.0+

## 🐛 Troubleshooting

### Build fails with "cannot find symbol" errors

Make sure you have all required JARs in your `libs/` folder:
- All 4 architecture-specific JARs
- The Java wrapper JAR (`libtorrent4j-2.1.0-38.jar`)

### Play Store still shows 16KB error

1. Verify you're using AGP 8.5.1+
2. Check `packagingOptions` in build.gradle
3. Use APK Analyzer to verify alignment
4. Ensure you're not including old 4KB-aligned libraries

### App crashes on startup

Check logcat for `UnsatisfiedLinkError`. This usually means:
- Missing architecture-specific JAR
- Conflicting libtorrent versions
- ProGuard/R8 stripping required classes

Add to `proguard-rules.pro`:
```
-keep class org.libtorrent4j.swig.** { *; }
```

## 📚 Resources

- [Android 16KB Page Size Guide](https://developer.android.com/guide/practices/page-sizes)
- [Google Play 16KB Requirement Blog](https://android-developers.googleblog.com/2025/05/prepare-play-apps-for-devices-with-16kb-page-size.html)
- [libtorrent4j GitHub](https://github.com/aldenml/libtorrent4j)
- [TorrentStream-Android](https://github.com/TorrentStream/TorrentStream-Android)

## 🤝 Contributing

Contributions are welcome! If you find issues or have improvements:

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file

The underlying libtorrent4j library is licensed under MIT.  
The libtorrent C++ library is licensed under BSD.

## ⚠️ Disclaimer

These libraries are provided as-is for helping developers meet Google Play's 16KB page size requirement. Test thoroughly before production use.

## 🙏 Credits

- **libtorrent4j** by [Alden Torres](https://github.com/aldenml)
- **libtorrent** by Arvid Norberg and contributors
- Built with assistance from the Android developer community

---

**Need help?** Open an issue or check the [discussions](../../discussions) page.

**Found this useful?** ⭐ Star the repo to help others discover it!
