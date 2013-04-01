#!/bin/sh

# PATH rule
# => /mingw/bin32
# => /mingw/bin 

if [ -z ${JOB} ]; then
  JOB=4
fi
if ! [[ "${JOB}" =~ ^[0-9]+$ ]]; then
  JOB=4
fi

# step 0:
# extract source to /crossdev/src
# step 1: 
# patch gcc
# step 2:
# ./build-gcc.sh binutils runtime
# gmp mpfr mpc ppl cloog iconv pthreads
# step 3:
# copy files from prefix to build root (/mingw)
# step 4:
# ./build-gcc.sh gcc
# step 5: gdb need python
# ./build-gcc.sh expat gdb

# MUST use relational path
# gmp gcc
#
# MUST use full path
# runtime pthreads
#
make -f `dirname $0`/Makefile \
 JOB=${JOB} \
 NAME=twu2 \
 SUB_VER=1 \
 TARGET=x86_64-w64-mingw32 \
 ARCHIVE_STAGE=/crossdev/stage \
 THREAD=posix \
 GCC_PREFIX=/mingw \
 BINUTILS_SRC=../../../src/binutils-2.23.1 \
 BINUTILS_BUILD=/crossdev/build/binutils \
 BINUTILS_STAGE=/crossdev/stage/binutils \
 RUNTIME_SRC=/crossdev/src/mingw-w64-svn \
 RUNTIME_BUILD=/crossdev/build/runtime \
 RUNTIME_STAGE=/crossdev/stage/runtime \
 GMP_SRC=../../../src/gmp-5.1.1 \
 GMP_BUILD=/crossdev/build/gmp \
 GMP_STAGE=/crossdev/stage/support/gmp \
 MPFR_SRC=../../../src/mpfr-3.1.2 \
 MPFR_BUILD=/crossdev/build/mpfr \
 MPFR_STAGE=/crossdev/stage/support/mpfr \
 MPC_SRC=../../../src/mpc-1.0.1 \
 MPC_BUILD=/crossdev/build/mpc \
 MPC_STAGE=/crossdev/stage/support/mpc \
 PPL_SRC=../../../src/ppl-1.0 \
 PPL_BUILD=/crossdev/build/ppl \
 PPL_STAGE=/crossdev/stage/support/ppl \
 CLOOG_SRC=../../../src/cloog-0.18.0 \
 CLOOG_BUILD=/crossdev/build/cloog \
 CLOOG_STAGE=/crossdev/stage/support/cloog \
 ICONV_SRC=../../../src/libiconv-1.14 \
 ICONV_BUILD=/crossdev/build/iconv \
 ICONV_STAGE=/crossdev/stage/support/iconv \
 PTHREADS_SRC=/crossdev/src/winpthreads \
 PTHREADS_BUILD=/crossdev/build/winpthreads \
 PTHREADS_STAGE=/crossdev/stage/support/winpthreads \
 GCC_SRC=../../src/gcc-4.8.0 \
 GCC_BUILD=/crossdev/build/gcc \
 GCC_STAGE=/crossdev/stage/gcc \
 EXPAT_SRC=../../../src/expat-2.0.1 \
 EXPAT_BUILD=/crossdev/build/expat \
 EXPAT_STAGE=/crossdev/stage/support/expat \
 GDB_SRC=../../../src/gdb-7.5.1 \
 GDB_BUILD=/crossdev/build/gdb \
 GDB_STAGE=/crossdev/stage/gdb \
 $*
