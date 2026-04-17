#!/usr/bin/env bash
set -e
export PATH=/opt/swift/usr/bin:$PATH
cd "$(dirname "$0")"
echo "Swift version: $(swift --version | head -1)"
echo ""
swift test
