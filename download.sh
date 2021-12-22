#!/bin/bash -xe

url_prefix="${1}"
bin_name="${2}"
version="${3}"
arch=$(echo "${4}" | cut -d"/" -f2)

dl_url="${url_prefix}/${version}/${bin_name}-linux-${arch}-${version}.tar.gz"

echo "Downloading \"${dl_url}\"..."

curl -Ls "${dl_url}" --output relaysrv.tar.gz \
  && tar -zxf relaysrv.tar.gz \
  && rm relaysrv.tar.gz
