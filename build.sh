#!/usr/bin/env bash
set -eu

CDIR="$(cd "$(dirname "$0")" && pwd)"
readonly CDIR
readonly build_dir=$CDIR/build
FZF_VERSION=$(cat fzf-version)
readonly FZF_VERSION

QUIET=''

while getopts A:K:q option; do
    case "${option}" in
        q) QUIET=1;;
        A) # shellcheck disable=SC2034
           ARCH=${OPTARG};;
        K) # shellcheck disable=SC2034
           KERNEL=${OPTARG};;
        *) ;;
    esac
done

rm -rf "$build_dir"
mkdir -p "$build_dir"
cp "$CDIR/pluginrc.zsh" "$build_dir/"

# fzf tags are prefixed with "v" since version 0.54.0.
# (https://github.com/junegunn/fzf/releases/tag/v0.54.0)
# The assets do not contain "v" though.
readonly portable_url="https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION#v}-linux_amd64.tar.gz"
tarname=$(basename "$portable_url")
readonly tarname

cd "$build_dir"

[ $QUIET ] && arg_q='-q' || arg_q=''
[ $QUIET ] && arg_s='-s' || arg_s=''
[ $QUIET ] && arg_progress='' || arg_progress='--show-progress'

if [ -x "$(command -v wget)" ]; then
    # shellcheck disable=SC2086
    wget $arg_q $arg_progress "$portable_url" -O "$tarname"
elif [ -x "$(command -v curl)" ]; then
    # shellcheck disable=SC2086
    curl $arg_s -L "$portable_url" -o "$tarname"
else
    echo Install wget or curl
fi

tar -xzf "$tarname"
mkdir bin
mv fzf bin/
rm "$tarname"
