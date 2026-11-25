#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
configuration="${1:-Debug}"
case "$configuration" in Debug|Release) ;; *) echo "Expected Debug or Release" >&2; exit 2 ;; esac
xcodebuild -version
xcodegen --version
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=Scripts python3 -m unittest discover -s Tests/CI
xcodegen generate
xcodebuild -version -sdk iphonesimulator
products="$PWD/.build/$configuration"
xcodebuild -project iPadValueTrace.xcodeproj -scheme ValueTraceExample \
  -configuration "$configuration" -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath "$products" CODE_SIGNING_ALLOWED=NO build
python3 Scripts/verify_linkage.py "$configuration" \
  "$products/Build/Products/$configuration-iphonesimulator/ValueTraceExample.app"
