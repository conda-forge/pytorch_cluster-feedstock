#!/bin/bash
# from https://github.com/conda-forge/pytorch_sparse-feedstock/blob/113b38f35b28b6e5b0262657c09b7cfac66b46e4/recipe/build.sh

set -euxo pipefail

if [[ ${cuda_compiler_version} != "None" && "$target_platform" == linux-64 ]]; then
    export FORCE_CUDA="1"
    export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
    export TORCH_CUDA_ARCH_LIST="${CF_TORCH_CUDA_ARCH_LIST}"
    # create a compiler shim because build checks whether $CC exists,
    # so we cannot pass flags in that variable; cannot use regular
    # compiler activation because nvcc doesn't understand most of the
    # flags, but we need to pass our main include directory at least.
    cat > $RECIPE_DIR/gcc_shim <<"EOF"
#!/bin/sh
exec $GCC -I$PREFIX/include "$@"
EOF
    chmod +x $RECIPE_DIR/gcc_shim
    export CC="$RECIPE_DIR/gcc_shim"
fi


echo "Installing"
${PYTHON} -m pip install . -vv
