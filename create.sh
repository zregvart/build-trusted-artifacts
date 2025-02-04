#!/bin/bash
# Creates specified trusted artifacts
set -o errexit
set -o nounset
set -o pipefail

# contains {result path}={artifact source path} pairs
artifact_pairs=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --store)
        store="$2"
        shift
        shift
        ;;
        --results)
        result_path="$2"
        shift
        shift
        ;;
        -*)
        echo "Unknown option $1"
        exit 1
        ;;
        *)
        artifact_pairs+=("$1")
        shift
        ;;
    esac
done

for artifact_pair in "${artifact_pairs[@]}"; do
    result_path="${artifact_pair/=*}"
    path="${artifact_pair/*=}"

    archive="$(mktemp).tar.gz"

    if [ ! -r "${path}" ]; then
        # non-existent paths result in empty archives
        tar -czf "${archive}" --files-from /dev/null
    elif [ -d "${path}" ]; then
        # archive the whole pathectory
        tar -czf "${archive}" -C "${path}" .
    else
        # archive a single file
        tar -czf "${archive}" -C "${path%/*}" "${path##*/}"
    fi

    sha256sum_output="$(sha256sum "${archive}")"
    digest="${sha256sum_output/ */}"
    artifact="${store}/sha256-${digest}.tar.gz"
    mv "${archive}" "${artifact}"
    echo -n "file:sha256-${digest}" > "${result_path}"

    echo Created artifact from "${path} (sha256:${digest})"
done
