#!/bin/sh

base_dir=$(cd $(dirname $0); pwd)

if [ $# -eq 1 -a "$1" = "init" ]; then
    julia --project=${base_dir} --eval 'using Pkg; Pkg.instantiate()' && echo 'Done'
else
    julia --project=${base_dir} --interactive --eval 'using AoC2025'
fi
