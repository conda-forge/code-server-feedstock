#!/bin/bash

set -euo pipefail
set -x

# export NODE_BINARY_PATH=${PREFIX}/bin/node-nbin

yarn

pushd lib/vscode
patch -p1 <../../ci/vscode.patch
yarn
npm rebuild
popd

yarn build
mkdir -p ${PREFIX}/share/code-server
mv build/* ${PREFIX}/share/code-server
mkdir -p ${PREFIX}/bin
cat <<'EOF' >${PREFIX}/bin/code-server
#!/bin/bash
node ${CONDA_PREFIX}/share/code-server/out/node/entry.js $*
EOF
chmod +x ${PREFIX}/bin/code-server
