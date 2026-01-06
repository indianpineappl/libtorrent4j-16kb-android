#!/bin/bash
# Package 16KB-aligned libtorrent4j native libraries into JARs
# This script packages the compiled .so files from libtorrent4j build output

set -e

SWIG_BIN="${1:-/path/to/libtorrent4j/swig/bin/release/android}"
OUTPUT_DIR="${2:-./libs}"
TEMP_DIR="/tmp/libtorrent4j-packaging"

if [ ! -d "$SWIG_BIN" ]; then
    echo "Error: SWIG build directory not found: $SWIG_BIN"
    echo "Usage: $0 <swig_bin_dir> [output_dir]"
    echo "Example: $0 /Users/you/libtorrent4j/swig/bin/release/android ./libs"
    exit 1
fi

echo "=========================================="
echo "Packaging 16KB-aligned libtorrent4j"
echo "=========================================="
echo ""
echo "Source: $SWIG_BIN"
echo "Output: $OUTPUT_DIR"
echo ""

# Create directories
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
mkdir -p "$OUTPUT_DIR"

# Package each architecture
for arch in arm64-v8a armeabi-v7a x86_64 x86; do
    echo "Packaging $arch..."
    
    SO_FILE="${SWIG_BIN}/${arch}/libtorrent4j.so"
    
    if [ ! -f "$SO_FILE" ]; then
        echo "Error: $SO_FILE not found"
        exit 1
    fi
    
    # Create JAR structure
    ARCH_DIR="${TEMP_DIR}/${arch}"
    mkdir -p "${ARCH_DIR}/lib/${arch}"
    
    # Copy .so file
    cp "$SO_FILE" "${ARCH_DIR}/lib/${arch}/"
    
    # Create JAR
    JAR_NAME="libtorrent4j-android-${arch}-16kb.jar"
    cd "${ARCH_DIR}"
    jar cf "${OUTPUT_DIR}/${JAR_NAME}" lib/
    
    echo "✓ Created ${JAR_NAME}"
done

# Clean up
rm -rf "$TEMP_DIR"

echo ""
echo "=========================================="
echo "Packaging complete!"
echo "=========================================="
echo ""
ls -lh "$OUTPUT_DIR"
echo ""
echo "JARs are ready in: $OUTPUT_DIR"
