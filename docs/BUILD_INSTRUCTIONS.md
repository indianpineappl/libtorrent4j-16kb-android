# Building libtorrent4j with 16KB Page Alignment

This guide explains how to build libtorrent4j from source with 16KB page size alignment for Android.

## Prerequisites

- **Docker Desktop** installed and running
- **Git** for cloning repositories
- **8+ GB RAM** available for Docker
- **50+ GB disk space** for build artifacts
- **2-4 hours** for complete build

## Step 1: Clone libtorrent4j

```bash
git clone https://github.com/aldenml/libtorrent4j.git
cd libtorrent4j
git submodule update --init --recursive
```

The submodule initialization will download libtorrent and all dependencies (~200MB).

## Step 2: Apply 16KB Alignment Patches

Edit the following configuration files to add the 16KB alignment linker flag:

### `swig/config/android-arm64-config.jam`

Add after the `<linkflags>-Wl,--no-rosegment` line:

```jam
<linkflags>-Wl,-z,max-page-size=16384
```

### `swig/config/android-arm-config.jam`

Add the same line:

```jam
<linkflags>-Wl,-z,max-page-size=16384
```

### `swig/config/android-x86_64-config.jam`

Add the same line:

```jam
<linkflags>-Wl,-z,max-page-size=16384
```

### `swig/config/android-x86-config.jam`

Add the same line:

```jam
<linkflags>-Wl,-z,max-page-size=16384
```

## Step 3: Build Docker Image

```bash
cd swig/android-build
docker build -t lt4j:latest .
```

This will take **30-60 minutes** on first run. The image includes:
- Android NDK r26
- Boost libraries
- OpenSSL for all architectures
- Build tools and dependencies

## Step 4: Build Native Libraries

Build each architecture separately:

```bash
# ARM 64-bit (most important - modern devices)
./build-arm64.sh

# ARM 32-bit (older devices)
./build-arm.sh

# x86 64-bit (emulators)
./build-x86_64.sh

# x86 32-bit (older emulators)
./build-x86.sh
```

Each build takes **10-20 minutes**. Total time: ~1-2 hours.

## Step 5: Verify Build Output

Check that `.so` files were created:

```bash
ls -lh ../../bin/release/android/*/libtorrent4j.so
```

You should see:
- `arm64-v8a/libtorrent4j.so` (~16 MB)
- `armeabi-v7a/libtorrent4j.so` (~13 MB)
- `x86_64/libtorrent4j.so` (~16 MB)
- `x86/libtorrent4j.so` (~16 MB)

## Step 6: Package into JARs

Use the provided packaging script:

```bash
cd /path/to/libtorrent4j-16kb-android
./build-scripts/package-jars.sh /path/to/libtorrent4j/swig/bin/release/android ./libs
```

This creates architecture-specific JARs in the `libs/` directory.

## Step 7: Verify 16KB Alignment

To verify the libraries are properly aligned, you can use `readelf` (Linux/WSL) or check in Android Studio:

### Using readelf (if available):

```bash
# Extract .so from JAR
unzip -j libs/libtorrent4j-android-arm64-v8a-16kb.jar lib/arm64-v8a/libtorrent4j.so

# Check alignment
readelf -l libtorrent4j.so | grep LOAD
```

Look for `Align: 0x4000` (16384 in hex = 16KB).

### Using Android Studio APK Analyzer:

1. Build your app with the JARs
2. Build → Analyze APK
3. Open the APK/AAB
4. Check `lib/` folder for alignment warnings

## Troubleshooting

### Docker build fails

- Ensure Docker Desktop has enough resources (8GB+ RAM)
- Check Docker is running: `docker ps`
- Try cleaning Docker: `docker system prune -a`

### Submodule errors

```bash
git submodule update --init --recursive --force
```

### Build fails with "Jamfile not found"

This means submodules weren't initialized. Run:

```bash
cd /path/to/libtorrent4j
git submodule update --init --recursive
```

### Platform mismatch warnings

If you see "platform (linux/amd64) does not match (linux/arm64/v8)", this is normal on Apple Silicon Macs. The build will still work.

### Out of disk space

The build requires ~50GB. Clean up Docker images:

```bash
docker system df
docker system prune -a
```

## Build Automation Script

For convenience, you can create a script to build all architectures:

```bash
#!/bin/bash
cd swig/android-build

# Build Docker image if needed
if [[ "$(docker images -q lt4j:latest 2> /dev/null)" == "" ]]; then
    docker build -t lt4j:latest .
fi

# Build all architectures
./build-arm64.sh
./build-arm.sh
./build-x86_64.sh
./build-x86.sh

echo "Build complete! Libraries in: ../../bin/release/android/"
```

## Next Steps

After building:

1. Package the JARs using the provided script
2. Test in your Android app
3. Verify 16KB compliance with APK Analyzer
4. Submit to Play Store

## Additional Resources

- [libtorrent4j Documentation](https://github.com/aldenml/libtorrent4j)
- [Android NDK Guide](https://developer.android.com/ndk/guides)
- [Docker Documentation](https://docs.docker.com/)
