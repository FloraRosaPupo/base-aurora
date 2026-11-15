#!/usr/bin/env bash
set -euo pipefail

# Exact SDK used for the verified web release. No account secrets are required.
AURORA_FLUTTER_VERSION=3.50.0
AURORA_FLUTTER_REVISION=ab2912035e160d9cad6306df307576da6128ebdb
AURORA_FLUTTER_SDK="${AURORA_FLUTTER_SDK:-/tmp/base-aurora-flutter-${AURORA_FLUTTER_VERSION}}"

if [[ ! -x "${AURORA_FLUTTER_SDK}/bin/flutter" ]]; then
  git clone --depth 1 --branch "$AURORA_FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$AURORA_FLUTTER_SDK"
fi
AURORA_ACTUAL_REVISION="$(git -C "$AURORA_FLUTTER_SDK" rev-parse HEAD)"
if [[ "$AURORA_ACTUAL_REVISION" != "$AURORA_FLUTTER_REVISION" ]]; then
  printf 'Flutter SDK revision differs from the verified release.\n' >&2
  exit 1
fi

"${AURORA_FLUTTER_SDK}/bin/flutter" config --no-analytics
"${AURORA_FLUTTER_SDK}/bin/flutter" pub get
"${AURORA_FLUTTER_SDK}/bin/flutter" test test/simulation_test.dart
node --test backend/test/*.test.mjs
"${AURORA_FLUTTER_SDK}/bin/flutter" build web --release --output dist --no-wasm-dry-run
