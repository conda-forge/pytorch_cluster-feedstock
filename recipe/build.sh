#!/bin/bash
# from https://github.com/conda-forge/pytorch_sparse-feedstock/blob/113b38f35b28b6e5b0262657c09b7cfac66b46e4/recipe/build.sh

set -euxo pipefail

if [[ ${cuda_compiler_version} != "None" && "$target_platform" == linux-64 ]]; then
    export TORCH_CUDA_ARCH_LIST="3.5;5.0"
    export FORCE_CUDA="1"
    if [[ ${cuda_compiler_version} == 11.8 ]]; then
        export TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9+PTX"
        export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
    elif [[ ${cuda_compiler_version} == 12.0 ]]; then
        export TORCH_CUDA_ARCH_LIST="5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"
        # $CUDA_HOME not set in CUDA 12.0. Using $PREFIX
        export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
    elif [[ ${cuda_compiler_version} == 12.6 ]]; then
        export TORCH_CUDA_ARCH_LIST="5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"
        export CUDA_TOOLKIT_ROOT_DIR="${PREFIX}"
    else
        echo "unsupported cuda version. edit build_pytorch.sh"
        exit 1
    fi
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
