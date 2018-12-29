#!/bin/bash

root_path="${1}"
output="${2}"

if [ -f "${output}" ]; then
    rm -fv ${output}
fi

for f in ${root_path}/converted/*.gz
do
    zcat ${f} | sort --random-sort | head -n3 >> ${output}
done
