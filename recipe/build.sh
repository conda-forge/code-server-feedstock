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
