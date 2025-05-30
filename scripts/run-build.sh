#!/bin/bash
set -e

echo "Received parameters: $@"

IOS_MODE="DebugDevelopment"
ANDROID_MODE="developmentDebug"
SCHEME="New Expensify Dev"
APP_ID="com.expensify.chat.dev"

GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Function to print error message and exit
function print_error_and_exit {
    echo -e "${RED}Error: Invalid invocation. Please use one of: [ios, ipad, ipad-sm, android].${NC}"
    exit 1
}

# Assign the arguments to variables if arguments are correct
if [ "$#" -ne 1 ] || [[ "$1" != "--ios" && "$1" != "--ipad" && "$1" != "--ipad-sm" && "$1" != "--android" && "$1" != "--android-apk" && "$1" != "--ios-ipa"  && "$1" != "--export-sh" ]]; then
    print_error_and_exit
fi

BUILD="$1"

# See if we're in the HybridApp repo
IS_HYBRID_APP_REPO=$(scripts/is-hybrid-app.sh)

# See if we should force standalone NewDot build
NEW_DOT_FLAG="${STANDALONE_NEW_DOT:-false}"

 if [[ "$IS_HYBRID_APP_REPO" == "true" && "$NEW_DOT_FLAG" == "false" ]]; then
    # Set HybridApp-specific arguments
    IOS_MODE="Debug"
    ANDROID_MODE="Debug"
    SCHEME="Expensify Dev"
    APP_ID="org.me.mobiexpensifyg.dev"

    # Build Yapl JS
    cd Mobile-Expensify && npm run grunt:build:shared && cd ..

    echo -e "\n${GREEN}Starting a HybridApp build!${NC}"
    export CUSTOM_APK_NAME="Expensify-debug.apk"
    export IS_HYBRID_APP="true"
else
    echo -e "\n${GREEN}Starting a standalone NewDot build!${NC}"
    echo $ANDROID_MODE
    unset CUSTOM_APK_NAME
fi

# Check if the argument is one of the desired values
case "$BUILD" in
    --ios)
        npx rnef run:ios --configuration $IOS_MODE --scheme "$SCHEME"
        ;;
    --ipad)
        npx rnef run:ios --simulator "iPad Pro (12.9-inch) (6th generation)" --configuration $IOS_MODE --scheme "$SCHEME"
        ;;
    --ipad-sm)
        npx rnef run:ios --simulator "iPad Pro (11-inch) (4th generation)" --configuration $IOS_MODE --scheme "$SCHEME"
        ;;
    --android)
        npx rnef run:android --variant $ANDROID_MODE --app-id $APP_ID --active-arch-only --verbose
        ;;
    --android-tt)
        npx rnef run:android --variant $ANDROID_MODE --app-id $APP_ID --active-arch-only --binary-path "./Mobile-Expensify/Android/build/outputs/apk/debug/Expensify-debug.apk"
        ;;
    --android-apk)
        npx rnef build:android --variant $ANDROID_MODE --active-arch-only
        ;;
    --ios-ipa)
        npx rnef build:ios --configuration $IOS_MODE --scheme "$SCHEME" --destination "simulator"	 --verbose
        ;;
    --export-sh)
        export SCHEME="$SCHEME"
        export IOS_MODE="$IOS_MODE"
        export ANDROID_MODE="$$ANDROID_MODE"
        echo -e "${GREEN}Environment variables exported:${NC}"
        echo "SCHEME=$SCHEME"
        echo "IOS_MODE=$IOS_MODE"
        echo "ANDROID_MODE=$ANDROID_MODE"
        ;;
    *)
        print_error_and_exit
        ;;
esac
