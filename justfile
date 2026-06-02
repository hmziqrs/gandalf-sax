default:
    @just --list

mac subcommand: (_run subcommand)

[private]
_run subcommand:
    #!/usr/bin/env bash
    case "{{subcommand}}" in
        dev)   CONFIG="Debug"   ;;
        build) CONFIG="Release" ;;
        run)   CONFIG="Debug"   ;;
        *)
            echo "Unknown subcommand: {{subcommand}}"
            echo "Usage: just mac [dev|build|run]"
            exit 1
            ;;
    esac
    WORKSPACE="apple/Projects/macOS/GandalfMac.xcodeproj/project.xcworkspace"
    echo "Resolving packages…"
    xcodebuild -workspace "$WORKSPACE" -scheme GandalfMac -resolvePackageDependencies 2>&1 | tail -n 1
    echo "Building GandalfMac ($CONFIG)…"
    xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme GandalfMac \
        -configuration "$CONFIG" \
        -destination 'platform=macOS' \
        CODE_SIGNING_ALLOWED=NO \
        build | tail -n 5
    if [ "{{subcommand}}" = "run" ]; then
        APP=$(find ~/Library/Developer/Xcode/DerivedData/GandalfMac-*/Build/Products/"$CONFIG"/GandalfMac.app -maxdepth 0 -type d 2>/dev/null | head -1)
        if [ -z "$APP" ]; then
            echo "Error: could not find built app"
            exit 1
        fi
        echo "Launching $APP…"
        open "$APP"
    fi
