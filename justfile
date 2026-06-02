set shell := ["zsh", "-uc"]

default:
    @just --list

# macOS
[group('mac')]
dev:
    @just _mac Debug

# macOS
[group('mac')]
build:
    @just _mac Release

[private]
_mac config:
    @echo "Building GandalfMac ({{config}})…"
    xcodebuild \
        -workspace apple/Projects/macOS/GandalfMac.xcodeproj/project.xcworkspace \
        -scheme GandalfMac \
        -configuration {{config}} \
        -destination 'platform=macOS' \
        CODE_SIGNING_ALLOWED=NO \
        build | tail -n 5
