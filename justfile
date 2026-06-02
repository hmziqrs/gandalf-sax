default:
    @just --list

mac subcommand: (_run subcommand)

[private]
_run subcommand:
    #!/usr/bin/env bash
    set -euo pipefail
    case "{{subcommand}}" in
        dev)   CONFIG="Debug" ;;
        build) CONFIG="Release" ;;
        *)
            echo "Unknown subcommand: {{subcommand}}"
            echo "Usage: just mac [dev|build]"
            exit 1
            ;;
    esac
    echo "Building GandalfMac ($CONFIG)…"
    xcodebuild \
        -workspace apple/Projects/macOS/GandalfMac.xcodeproj/project.xcworkspace \
        -scheme GandalfMac \
        -configuration "$CONFIG" \
        -destination 'platform=macOS' \
        CODE_SIGNING_ALLOWED=NO \
        build | tail -n 5
