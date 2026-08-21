#!/bin/bash
EZA_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$EZA_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <eza_version> <build_version> [architecture]"
    echo "Example: $0 0.23.5 1 arm64"
    echo "Example: $0 0.23.5 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, armhf, all"
    exit 1
fi

UPSTREAM_URL="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}"

# Map a Debian architecture to the eza release asset. All three Linux builds
# are glibc-linked but need GLIBC_2.18 at most, so they run on every suite we
# target. Upstream publishes no i386, riscv64 or ppc64el binaries.
get_eza_release() {
    case "$1" in
        "amd64") echo "eza_x86_64-unknown-linux-gnu" ;;
        "arm64") echo "eza_aarch64-unknown-linux-gnu" ;;
        "armhf") echo "eza_arm-unknown-linux-gnueabihf" ;;
        *)       echo "" ;;
    esac
}

PACKAGE_DEPENDS="libc6 (>= 2.18), libgcc-s1"

# The completions and man pages are architecture independent and ship in their
# own archives, both of which extract into target/.
fetch_docs() {
    if [ -d "target/completions-${EZA_VERSION}" ] && [ -d "target/man-${EZA_VERSION}" ]; then
        echo "Using existing target/"
        return 0
    fi

    echo "Downloading completions and man pages for ${EZA_VERSION}..."
    rm -rf target || true

    if ! wget -q "${UPSTREAM_URL}/completions-${EZA_VERSION}.tar.gz" -O completions.tar.gz; then
        echo "❌ Failed to download completions-${EZA_VERSION}.tar.gz"
        return 1
    fi
    tar -xf completions.tar.gz && rm -f completions.tar.gz

    if ! wget -q "${UPSTREAM_URL}/man-${EZA_VERSION}.tar.gz" -O man.tar.gz; then
        echo "❌ Failed to download man-${EZA_VERSION}.tar.gz"
        return 1
    fi
    tar -xf man.tar.gz && rm -f man.tar.gz

    for f in "target/completions-${EZA_VERSION}/eza" "target/completions-${EZA_VERSION}/eza.fish" \
             "target/completions-${EZA_VERSION}/_eza" "target/man-${EZA_VERSION}/eza.1"; do
        if [ ! -s "$f" ]; then
            echo "❌ Expected file $f is missing or empty"
            return 1
        fi
    done
    echo "✅ Completions and man pages downloaded"
}

build_architecture() {
    local build_arch=$1
    local eza_release

    eza_release=$(get_eza_release "$build_arch")
    if [ -z "$eza_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64, armhf"
        return 1
    fi

    echo "Building for architecture: $build_arch using $eza_release"

    rm -rf "dist/$build_arch" || true
    mkdir -p "dist/$build_arch"

    # The binary archives contain a single top-level ./eza
    if ! wget -q "${UPSTREAM_URL}/${eza_release}.tar.gz" -O "dist/$build_arch/eza.tar.gz"; then
        echo "❌ Failed to download eza binary for $build_arch"
        return 1
    fi
    if ! tar -xf "dist/$build_arch/eza.tar.gz" -C "dist/$build_arch"; then
        echo "❌ Failed to extract eza binary for $build_arch"
        return 1
    fi
    rm -f "dist/$build_arch/eza.tar.gz"

    if [ ! -s "dist/$build_arch/eza" ]; then
        echo "❌ Unexpected archive layout for $build_arch (no eza binary)"
        return 1
    fi

    declare -a arr=("bookworm" "trixie" "forky" "sid")

    for dist in "${arr[@]}"; do
        FULL_VERSION="$EZA_VERSION-${BUILD_VERSION}~${dist}_${build_arch}"
        echo "  Building $FULL_VERSION"

        if ! docker build . -t "eza-$dist-$build_arch" \
            --build-arg DEBIAN_DIST="$dist" \
            --build-arg EZA_VERSION="$EZA_VERSION" \
            --build-arg BUILD_VERSION="$BUILD_VERSION" \
            --build-arg FULL_VERSION="$FULL_VERSION" \
            --build-arg ARCH="$build_arch" \
            --build-arg PACKAGE_DEPENDS="$PACKAGE_DEPENDS"; then
            echo "❌ Failed to build Docker image for $dist on $build_arch"
            return 1
        fi

        id="$(docker create "eza-$dist-$build_arch")"
        if ! docker cp "$id:/eza_$FULL_VERSION.deb" - > "./eza_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb package for $dist on $build_arch"
            return 1
        fi

        if ! tar -xf "./eza_$FULL_VERSION.deb"; then
            echo "❌ Failed to extract .deb contents for $dist on $build_arch"
            return 1
        fi
    done

    rm -rf "dist/$build_arch" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

if ! fetch_docs; then
    exit 1
fi

if [ "$ARCH" = "all" ]; then
    echo "🚀 Building eza $EZA_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    ARCHITECTURES=("amd64" "arm64" "armhf")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la eza_*.deb
else
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
