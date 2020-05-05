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
  ${PREFIX}/share/code-server/lib/vscode/node_modules/.cache \
  ${PREFIX}/share/code-server/lib/vscode/out/vs/workbench/*.map
