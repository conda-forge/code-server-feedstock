#!/bin/bash

set -euo pipefail

mkdir $PREFIX/share
cp -r code-server $PREFIX/share/
mkdir -p ${PREFIX}/bin
cat <<'EOF' >${PREFIX}/bin/code-server
#!/bin/bash
node ${CONDA_PREFIX}/share/code-server/out/node/entry.js $*
EOF
chmod +x ${PREFIX}/bin/code-server

# Remove unnecessary resources
find ${PREFIX}/share/code-server -name '*.map' -delete
rm -rf \
  ${PREFIX}/share/code-server/node \
  ${PREFIX}/share/code-server/lib/node \
  ${PREFIX}/share/code-server/lib/lib* \
  ${PREFIX}/share/code-server/lib/vscode/node_modules/vscode-sqlite3/build/Release/obj* \
  ${PREFIX}/share/code-server/lib/vscode/node_modules/vscode-sqlite3/build/Release/sqlite3.a \
  ${PREFIX}/share/code-server/lib/vscode/node_modules/vscode-sqlite3/deps \
  ${PREFIX}/share/code-server/lib/vscode/node_modules/.cache \
  ${PREFIX}/share/code-server/lib/vscode/out/vs/workbench/*.map \
  ${PREFIX}/share/code-server/lib/vscode/node_modules/@coder/requirefs/coverage
find ${PREFIX}/share/code-server/ -name obj.target | xargs rm -r
