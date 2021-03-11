#!/bin/bash

set -exuo pipefail

export npm_config_build_from_source=true
if [[ "${target_platform}" == "osx-arm64" ]] || [[ "${target_platform}" == "linux-aarch64" ]]; then
  export npm_config_arch=arm64
  export npm_config_target_arch=arm64
else
  export npm_config_arch=x64
  export npm_config_target_arch=x64
fi

# Build from source
pushd code-server
  git init .
  git add .
  git commit -m "Initial commit"
  git tag ${PKG_VERSION}
  yarn --frozen-lockfile
  yarn build
  yarn build:vscode
  yarn release
  yarn release:standalone
  # TODO: Adjust the code-server script to reference node from PATH
  # yarn test:standalone-release
  yarn package
popd

# Install tarball into ${PREFIX}
mkdir -p ${PREFIX}/share
pushd code-server/release-packages
  tar xf code-server-*.tar.gz
  rm code-server-*.tar.gz
  mv code-server-* code-server
  cp -r code-server ${PREFIX}/share/
popd

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/share/code-server/extensions
cat <<'EOF' >${PREFIX}/bin/code-server
#!/bin/bash

PREFIX_DIR=$(dirname ${BASH_SOURCE}})

# Make PREDIX_DIR absolute
if [[ $(uname) == 'Linux' ]]; then
  PREFIX_DIR=$(readlink -f ${PREFIX_DIR})
else
  pushd ${PREFIX_DIR}
  PREFIX_DIR=$(pwd -P)
  popd
fi

# Go one level up
PREFIX_DIR=$(dirname ${PREFIX_DIR})

EXTENSIONS_DIR_ARG="--extensions-dir"
EXTENSIONS_DIR_VAL="${PREFIX_DIR}/share/code-server/extensions"
if [[ "$*" != *"${EXTENSIONS_DIR_ARG}"* ]]; then
    set -- "$*" "${EXTENSIONS_DIR_ARG} ${EXTENSIONS_DIR_VAL}"
fi

node ${PREFIX_DIR}/share/code-server/out/node/entry.js $*
EOF
chmod +x ${PREFIX}/bin/code-server

# Directly check whether the code-server call also works inside of conda-build
code-server --help

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
