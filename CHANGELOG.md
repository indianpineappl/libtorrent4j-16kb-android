# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-01-07

### Added
- Initial release of 16KB page size compliant libtorrent4j for Android
- Pre-built JARs for all Android architectures:
  - arm64-v8a (ARM 64-bit)
  - armeabi-v7a (ARM 32-bit)
  - x86_64 (x86 64-bit)
  - x86 (x86 32-bit)
- Based on libtorrent4j 2.1.0-38
- Compiled with `-Wl,-z,max-page-size=16384` for Google Play compliance
- Comprehensive documentation and usage examples
- Build scripts for rebuilding from source
- Docker-based build system

### Features
- ✅ Google Play 16KB page size compliant
- ✅ Compatible with Android 6.0+ (API 23+)
- ✅ Works with TorrentStream-Android wrapper
- ✅ Direct libtorrent4j API support
- ✅ All Android architectures supported

### Notes
- Required for Play Store submission starting November 1, 2025
- Replaces standard libtorrent4j libraries that use 4KB alignment
- Fully compatible with existing libtorrent4j code
