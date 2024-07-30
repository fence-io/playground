#!/bin/bash

shopt -s expand_aliases

install_dir=$HOME/.kubewarden
mkdir -p ${install_dir}
trap "popd >/dev/null" EXIT
pushd ${install_dir} > /dev/null
release_archive=kwctl-linux-x86_64.zip
release_archive_url=https://github.com/kubewarden/kwctl/releases/download/v1.14.0/${release_archive}
curl -sL ${release_archive_url} -o ${release_archive}
unzip ${release_archive} kwctl-linux-x86_64
rm ${release_archive}
chmod +x kwctl-linux-x86_64

export PATH="$install_dir:$PATH"
