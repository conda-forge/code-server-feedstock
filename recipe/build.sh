#!/bin/bash

set -euo pipefail
set -x

export MINIFY="true"
export VERSION=$(grep version ./package.json | head -1 | awk -F: '{ print $2 }' | sed 's/[",]//g' | tr -d '[:space:]')

yarn
npm install -g typescript

pushd lib/vscode
patch -p1 <../../ci/vscode.patch
yarn
popd

rm -rf lib/vscode/node_modules/playwright-core/.local-webkit

yarn build
mkdir -p ${PREFIX}/share/code-server
mv build/* ${PREFIX}/share/code-server
mkdir -p ${PREFIX}/bin
cat <<'EOF' >${PREFIX}/bin/code-server
#!/bin/bash
node ${CONDA_PREFIX}/share/code-server/out/node/entry.js $*
EOF
chmod +x ${PREFIX}/bin/code-server
