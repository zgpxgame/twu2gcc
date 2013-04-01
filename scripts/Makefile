
# build name (passed from build-gcc.sh)
NAME = twu2

# thread mode: posix or win32 (depend on the target, default is posix)
THREAD = posix

# current system's runtime folder
TARGET_DIR = $(GCC_PREFIX)/$(TARGET)

# current GCC version
GCCVERSION = $(shell gcc --version | grep ^gcc | sed 's/^.* //g')

# this Makefile
where-am-i = $(lastword $(MAKEFILE_LIST))
MKFILE = $(call where-am-i)

# make job concurrent number (JOB passed from build-gcc.sh)
JOBARG =
ifneq ($(JOB),)
  ifneq ($(JOB),1)
    JOBARG = -j$(JOB)
  endif
endif

# PGO build for gcc64
PGOBUILD =
ifeq ($(PGO),1)
  # PGO profiled string
  PGOBUILD = profiled
  # PGO build is not support job
  JOBARG =
endif

# gcc build folder
GCCBUILD32 = $(GCC_BUILD)$(PGOBUILD)_32_$(THREAD)
GCCBUILD64 = $(GCC_BUILD)$(PGOBUILD)_64_$(THREAD)
GCCBUILDNOBS = $(GCC_BUILD)_nobs_64_$(THREAD)

# gcc stage folder
GCCSTAGE32 = $(GCC_STAGE)$(PGOBUILD)_32_$(THREAD)
GCCSTAGE64 = $(GCC_STAGE)$(PGOBUILD)_64_$(THREAD)
GCCSTAGENOBS = $(GCC_STAGE)_nobs_64_$(THREAD)

ENABLE_LTO = 0
# LTO flags
LTOFLAGS =
LTOFLAGS32 =
ifeq ($(ENABLE_LTO),1)
  LTOFLAGS = -flto -fuse-linker-plugin
  LTOFLAGS32 = -flto 
endif

# LTO
#CFGS = -march=x86-64 -O2 -pipe $(LTOFLAGS)
#LDFGS = $(LTOFLAGS)

# not LTO
CFGS = -march=x86-64 -O2 -pipe
LDFGS = 

# error message if not from build-gcc.sh
ERR = $(error Please execute via build-gcc.sh)

# check some environment, make sure we're executed from build-gcc.sh
ifndef BINUTILS_BUILD
$(ERR)
endif
ifndef RUNTIME_BUILD
$(ERR)
endif
ifndef GMP_BUILD
$(ERR)
endif
ifndef MPFR_BUILD
$(ERR)
endif
ifndef MPC_BUILD
$(ERR)
endif
ifndef PPL_BUILD
$(ERR)
endif
ifndef CLOOG_BUILD
$(ERR)
endif
ifndef ICONV_BUILD
$(ERR)
endif
ifndef PTHREADS_BUILD
$(ERR)
endif
ifndef GCC_BUILD
$(ERR)
endif

# show supported build target
.PHONY: info
info:
	@echo "make target:"
	@echo "	binutils64	=> 64 bits binutils"
	@echo "	binutils32	=> 32 bits binutils"
	@echo "	binutils  	=> binutils32 and binutils64"
	@echo "	runtime   	=> mingw-w64 runtime"
	@echo "	gmp64      	=> 64 bits GMP"
	@echo "	gmp32      	=> 32 bits GMP"
	@echo "	gmp        	=> gmp32 and gmp64"
	@echo "	mpfr64     	=> 64 bits MPFR"
	@echo "	mpfr32     	=> 32 bits MPFR"
	@echo "	mpfr       	=> mpfr32 and mprf64"
	@echo "	mpc64      	=> 64 bits MPC"
	@echo "	mpc32      	=> 32 bits MPC"
	@echo "	mpc        	=> mpc32 and mpc64"
	@echo "	ppl64      	=> 64 bits PPL"
	@echo "	ppl32      	=> 32 bits PPL"
	@echo "	ppl        	=> ppl32 and ppl64"
	@echo "	cloog64    	=> 64 bits CLOOG"
	@echo "	cloog32    	=> 32 bits CLOOG"
	@echo "	cloog      	=> cloog32 and cloog64"
	@echo "	iconv64    	=> 64 bits libiconv"
	@echo "	iconv32    	=> 32 bits libiconv"
	@echo "	iconv      	=> iconv32 and iconv64"
	@echo "	pthreads64 	=> 64 bits winpthreads"
	@echo "	pthreads32 	=> 32 bits winpthreads"
	@echo "	pthreads   	=> pthreads32 and pthreads64"
	@echo "	expat64    	=> 64 bits expat"
	@echo "	expat32    	=> 32 bits expat"
	@echo "	expat      	=> expat32 and expat64"
	@echo "	gdb64      	=> 64 bits GDB"
	@echo "	gdb        	=> 64 bits GDB"
	@echo "	gcc_nobs   	=> 64 bits gcc posix thread no bootstrap"
	@echo "	gcc	   	=> 64 bits gcc posix thread"
	@echo "	gcc_posix  	=> 64 bits gcc posix thread"
	@echo "	gcc_win32  	=> 64 bits gcc win32 thread"
	@echo "	gcc_posix_pgo   => 64 bits gcc posix thread with PGO"
	@echo "	gcc_win32_pgo   => 64 bits gcc win32 thread with PGO"
	@echo "	gcc32	    	=> 32 bits gcc posix thread"
	@echo "	gcc32_posix	=> 32 bits gcc posix thread"
	@echo "	gcc32_win32 	=> 32 bits gcc win32 thread"
	@echo "	gcc32_posix_pgo	=> 32 bits gcc posix thread with PGO"
	@echo "	gcc32_win32_pgo	=> 32 bits gcc win32 thread with PGO"

# binutils, for both 32bits and 64bits
.PHONY: binutils
binutils: binutils32 binutils64

# binutils32, 32bits binutils
.PHONY: binutils32
binutils32: binutils32_build
	# strip *.exe, *.dll
	-find $(BINUTILS_STAGE)/32 -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(BINUTILS_STAGE)/32 -iname '*.a' | xargs -r strip --strip-debug
	# remove *.la, we don't want this
	-find $(BINUTILS_STAGE)/32 -iname '*.la' | xargs -r rm -f
	# move lib32 to lib, and remove lib32
	-mv $(BINUTILS_STAGE)/32/lib32/* $(BINUTILS_STAGE)/32/lib/
	-rm -rf $(BINUTILS_STAGE)/32/lib32
	# copy ansidecl.h to runtime's include folder
	# because when we build gcc, it can't get it (because -nostdinc)
	-mkdir -p $(BINUTILS_STAGE)/32/$(TARGET)/include
	-cp $(BINUTILS_STAGE)/32/include/ansidecl.h $(BINUTILS_STAGE)/32/$(TARGET)/include/
	# make tarball
	-rm -f $(ARCHIVE_STAGE)/binutils_32.tar.xz
	cd $(BINUTILS_STAGE)/32 \
	&& tar Jcvf $(ARCHIVE_STAGE)/binutils_32.tar.xz *

.PHONY: binutils32_build
binutils32_build: $(BINUTILS_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(BINUTILS_BUILD)/32 \
	&& $(MAKE) -C $(BINUTILS_BUILD)/32 install \
	  prefix=$(BINUTILS_STAGE)/32
$(BINUTILS_BUILD)/32/Makefile:
	rm -fR $(BINUTILS_BUILD)/32
	mkdir -p $(BINUTILS_BUILD)/32
	cd $(BINUTILS_BUILD)/32 \
	&& echo "int _dowildcard = -1;" >$(BINUTILS_BUILD)/32/glob_enable.c \
	&& gcc $(CFGS) -m32 -c -o $(BINUTILS_BUILD)/32/glob_enable.o \
	  $(BINUTILS_BUILD)/32/glob_enable.c \
	&& $(BINUTILS_SRC)/configure \
	  --prefix=$(GCC_PREFIX) \
	  --build=$(TARGET) \
	  --enable-targets=$(TARGET),i686-w64-mingw32 \
	  --enable-multilib \
	  --enable-64-bit-bfd \
	  --disable-ppl-version-check \
	  --disable-cloog-version-check \
	  --enable-lto \
	  --enable-gold \
	  --enable-ld \
	  --with-gmp=$(TARGET_DIR) \
	  --with-mpfr=$(TARGET_DIR) \
	  --with-mpc=$(TARGET_DIR) \
	  --with-ppl=$(TARGET_DIR) \
	  --with-cloog=$(TARGET_DIR) \
	  --enable-cloog-backend=isl \
	  --disable-nls \
	  CFLAGS="$(CFGS) -m32" \
	  LDFLAGS="$(LDFGS) -s -m32 -Wl,$(BINUTILS_BUILD)/32/glob_enable.o"

# binutils64, 64bits binutils
.PHONY: binutils64
binutils64: binutils64_build
	# strip *.exe, *.dll
	-find $(BINUTILS_STAGE)/64 -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(BINUTILS_STAGE)/64 -iname '*.a' | xargs -r strip --strip-debug
	# remove *.la, we don't want this
	-find $(BINUTILS_STAGE)/64 -iname '*.la' | xargs -r rm -f
	# copy ansidecl.h to runtime's include folder
	# because when we build gcc, it can't get it (because -nostdinc)
	-mkdir -p $(BINUTILS_STAGE)/64/$(TARGET)/include
	-cp $(BINUTILS_STAGE)/64/include/ansidecl.h $(BINUTILS_STAGE)/64/$(TARGET)/include/
	# make tarball
	-rm -f $(ARCHIVE_STAGE)/binutils_64.tar.xz
	cd $(BINUTILS_STAGE)/64 \
	&& tar Jcvf $(ARCHIVE_STAGE)/binutils_64.tar.xz *

.PHONY: binutild64_build
binutils64_build: $(BINUTILS_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(BINUTILS_BUILD)/64 \
	&& $(MAKE) -C $(BINUTILS_BUILD)/64 install \
	  prefix=$(BINUTILS_STAGE)/64
$(BINUTILS_BUILD)/64/Makefile:
	rm -fR $(BINUTILS_BUILD)/64
	mkdir -p $(BINUTILS_BUILD)/64
	cd $(BINUTILS_BUILD)/64 \
	&& echo "int _dowildcard = -1;" >$(BINUTILS_BUILD)/64/glob_enable.c \
	&& gcc $(CFGS) -m64 -c -o $(BINUTILS_BUILD)/64/glob_enable.o \
	  $(BINUTILS_BUILD)/64/glob_enable.c \
	&& $(BINUTILS_SRC)/configure \
	  --prefix=$(GCC_PREFIX) \
	  --build=$(TARGET) \
	  --enable-targets=$(TARGET),i686-w64-mingw32 \
	  --enable-multilib \
	  --enable-64-bit-bfd \
	  --disable-ppl-version-check \
	  --disable-cloog-version-check \
	  --enable-lto \
	  --enable-ld \
	  --enable-gold \
	  --enable-sysroot \
	  --with-sysroot=/mingw \
	  --with-gmp=$(TARGET_DIR) \
	  --with-mpfr=$(TARGET_DIR) \
	  --with-mpc=$(TARGET_DIR) \
	  --with-ppl=$(TARGET_DIR) \
	  --with-cloog=$(TARGET_DIR) \
	  --enable-cloog-backend=isl \
	  --disable-nls \
	  CFLAGS="$(CFGS) -m64" \
	  LDFLAGS="$(LDFGS) -s -m64 -Wl,$(BINUTILS_BUILD)/64/glob_enable.o"

# mingw64 runtime
.PHONY: runtime
runtime: runtime_build
	# strip *.exe, *.dll
	-find $(RUNTIME_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(RUNTIME_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	-find $(RUNTIME_STAGE)/$(TARGET) -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/mingw64-runtime.tar.xz 
	# when normal use, if use lib32 for 32bits
	# we need to create junction point lib/32 to lib32
	cd $(RUNTIME_STAGE)/ \
	&& tar Jcvf $(ARCHIVE_STAGE)/mingw64-runtime.tar.xz *

.PHONY: runtime_build
runtime_build: $(RUNTIME_BUILD)/Makefile
	$(MAKE) $(JOBARG) -C $(RUNTIME_BUILD) \
	&& $(MAKE) -C $(RUNTIME_BUILD) install \
	  prefix=$(RUNTIME_STAGE)/$(TARGET)
$(RUNTIME_BUILD)/Makefile:
	rm -fR $(RUNTIME_BUILD)
	mkdir -p $(RUNTIME_BUILD)
	# we might need to use the include folder in source
	# because there maybe some new definition not in the current runtime
	cd $(RUNTIME_BUILD) \
	&& $(RUNTIME_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --enable-lib32 \
	  --enable-sdk=all \
	  --enable-wildcard \
	  --with-libraries=libmangle \
	  --with-tools=all \
	  CFLAGS="$(CFGS) -I${RUNTIME_SRC}/mingw-w64-headers/include"

# GMP, some others depend on this
.PHONY: gmp
gmp: gmp32 gmp64
	-rm -rf $(GMP_STAGE)/x
	mkdir -p $(GMP_STAGE)/x
	# strip *.exe, *.dll
	-find $(GMP_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(GMP_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(GMP_STAGE)/64 $(GMP_STAGE)/x/$(TARGET)
	cp -a $(GMP_STAGE)/32/lib32 $(GMP_STAGE)/x/$(TARGET)/lib32
	# 32bits gmp.h and 64bits gmp.h are different
	# so we need to add some check to load the correct header
	echo "#ifndef __WIN64__">$(GMP_STAGE)/x/$(TARGET)/include/gmp_64.h
	echo "#include <gmp_32.h>">>$(GMP_STAGE)/x/$(TARGET)/include/gmp_64.h
	echo "#else">>$(GMP_STAGE)/x/$(TARGET)/include/gmp_64.h
	cat $(GMP_STAGE)/x/$(TARGET)/include/gmp.h>>$(GMP_STAGE)/x/$(TARGET)/include/gmp_64.h
	echo "#endif /* __WIN64__ */">>$(GMP_STAGE)/x/$(TARGET)/include/gmp_64.h
	rm -f $(GMP_STAGE)/x/$(TARGET)/include/gmp.h
	mv $(GMP_STAGE)/x/$(TARGET)/include/gmp_64.h $(GMP_STAGE)/x/$(TARGET)/include/gmp.h
	cp $(GMP_STAGE)/32/include/gmp.h $(GMP_STAGE)/x/$(TARGET)/include/gmp_32.h
	# move 64 bin
	-mv $(GMP_STAGE)/x/$(TARGET)/bin $(GMP_STAGE)/x/
	# create bin if not exist
	-mkdir -p $(GMP_STAGE)/x/bin
	# move 32 bin/*.dll to /x/bin
	-mv -f $(GMP_STAGE)/32/bin/*.dll $(GMP_STAGE)/x/bin/
	# move lib32/*.dll to /x/bin
	-mv $(GMP_STAGE)/x/$(TARGET)/lib32/*.dll $(GMP_STAGE)/x/bin/
	# move lib/*.dll to /x/bin
	-mv $(GMP_STAGE)/x/$(TARGET)/lib/*.dll $(GMP_STAGE)/x/bin/
	-rm -rf $(GMP_STAGE)/32
	-rm -rf $(GMP_STAGE)/64
	# we don't need any execute file
	-rm -rf $(GMP_STAGE)/x/bin/*.exe
	-rm -rf $(GMP_STAGE)/x/bin32/*.exe
	-rm -rf $(GMP_STAGE)/x/$(TARGET)/share/doc
	# we don't need *.la
	-find $(GMP_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/gmp.tar.xz 
	cd $(GMP_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/gmp.tar.xz *

.PHONY: gmp32
gmp32: $(GMP_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(GMP_BUILD)/32 \
	&& $(MAKE) -C $(GMP_BUILD)/32 install \
	  prefix=$(GMP_STAGE)/32
$(GMP_BUILD)/32/Makefile:
	rm -fR $(GMP_BUILD)/32
	mkdir -p $(GMP_BUILD)/32
	cd $(GMP_BUILD)/32 \
	&& $(GMP_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --enable-cxx \
	  --disable-static \
	  --enable-shared \
	  --libdir=$$\{prefix}/lib32 \
	  LD="ld.exe -m i386pe" \
	  CFLAGS="$(CFGS) -m32" \
	  CXXFLAGS="$(CFGS) -m32" \
	  LDFLAGS="$(LDFGS) -m32 -s" \
	  ABI=32

.PHONY: gmp64
gmp64: $(GMP_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(GMP_BUILD)/64 \
	&& $(MAKE) -C $(GMP_BUILD)/64 install \
	  prefix=$(GMP_STAGE)/64
$(GMP_BUILD)/64/Makefile:
	rm -fR $(GMP_BUILD)/64
	mkdir -p $(GMP_BUILD)/64
	cd $(GMP_BUILD)/64 \
	&& $(GMP_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --enable-cxx \
	  --disable-static \
	  --enable-shared \
	  CFLAGS="$(CFGS)" \
	  CXXFLAGS="$(CFGS)" \
	  LDFLAGS="$(LDFGS) -s" \
	  ABI=64

# MPFR, we need install GMP first, then build this
.PHONY: mpfr
mpfr: mpfr32 mpfr64
	-rm -rf $(MPFR_STAGE)/x
	mkdir -p $(MPFR_STAGE)/x
	# strip *.exe, *.dll
	-find $(MPFR_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(MPFR_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(MPFR_STAGE)/64 $(MPFR_STAGE)/x/$(TARGET)
	cp -a $(MPFR_STAGE)/32/lib32 $(MPFR_STAGE)/x/$(TARGET)/lib32
	# move 64 bin to /x
	-mv $(MPFR_STAGE)/x/$(TARGET)/bin $(MPFR_STAGE)/x/
	# create bin if not exist
	-mkdir -p $(MPFR_STAGE)/x/bin
	# move 32/bin/*.dll to /x/bin
	-mv $(MPFR_STAGE)/32/bin/*.dll $(MPFR_STAGE)/x/bin/
	# move lib32/*.dll to /x/bin
	-mv $(MPFR_STAGE)/x/$(TARGET)/lib32/*.dll $(MPFR_STAGE)/x/bin/
	# move lib/*.dll to /x/bin
	-mv $(MPFR_STAGE)/x/$(TARGET)/lib/*.dll $(MPFR_STAGE)/x/bin/
	# we don't need exe
	-rm f $(MPFR_STAGE)/x/$(TARGET)/bin/*.exe
	-rm -rf $(MPFR_STAGE)/32
	-rm -rf $(MPFR_STAGE)/64
	-rm -rf $(MPFR_STAGE)/x/$(TARGET)/share/doc
	-find $(MPFR_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/mpfr.tar.xz 
	cd $(MPFR_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/mpfr.tar.xz *

.PHONY: mpfr32
mpfr32: $(MPFR_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(MPFR_BUILD)/32 \
	&& $(MAKE) -C $(MPFR_BUILD)/32 install \
	  prefix=$(MPFR_STAGE)/32
$(MPFR_BUILD)/32/Makefile:
	rm -fR $(MPFR_BUILD)/32
	mkdir -p $(MPFR_BUILD)/32
	cd $(MPFR_BUILD)/32 \
	&& $(MPFR_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  --libdir=$$\{prefix}/lib32 \
	  CFLAGS="$(CFGS) -m32" LDFLAGS="$(LDFGS) -m32 -s"

.PHONY: mpfr64
mpfr64: $(MPFR_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(MPFR_BUILD)/64 \
	&& $(MAKE) -C $(MPFR_BUILD)/64 install \
	  prefix=$(MPFR_STAGE)/64
$(MPFR_BUILD)/64/Makefile:
	rm -fR $(MPFR_BUILD)/64
	mkdir -p $(MPFR_BUILD)/64
	cd $(MPFR_BUILD)/64 \
	&& $(MPFR_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  CFLAGS="$(CFGS)" LDFLAGS="$(LDFGS) -s"

# MPC, we need install GMP/MPFR first, then build this
.PHONY: mpc
mpc: mpc32 mpc64
	-rm -rf $(MPC_STAGE)/x
	mkdir -p $(MPC_STAGE)/x
	# strip *.exe, *.dll
	-find $(MPC_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(MPC_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(MPC_STAGE)/64 $(MPC_STAGE)/x/$(TARGET)
	cp -a $(MPC_STAGE)/32/lib32 $(MPC_STAGE)/x/$(TARGET)/lib32
	# move 64 bin to /x
	-mv $(MPC_STAGE)/x/$(TARGET)/bin $(MPC_STAGE)/x/
	# create bin if not exist
	-mkdir -p $(MPC_STAGE)/x/bin
	# move 32/bin/*.dll to /x/bin
	-mv $(MPC_STAGE)/32/bin/*.dll $(MPC_STAGE)/x/bin/
	# move lib32/*.dll to /x/bin
	-mv $(MPC_STAGE)/x/$(TARGET)/lib32/*.dll $(MPC_STAGE)/x/bin/
	# move lib/*.dll to /x/bin
	-mv $(MPC_STAGE)/x/$(TARGET)/lib/*.dll $(MPC_STAGE)/x/bin/
	# we don't need exe
	-rm -f $(MPC_STAGE)/x/bin/*.exe
	-rm -rf $(MPC_STAGE)/32
	-rm -rf $(MPC_STAGE)/64
	-rm -rf $(MPC_STAGE)/x/$(TARGET)/share/doc
	-find $(MPC_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/mpc.tar.xz 
	cd $(MPC_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/mpc.tar.xz *

.PHONY: mpc32
mpc32: $(MPC_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(MPC_BUILD)/32 \
	&& $(MAKE) -C $(MPC_BUILD)/32 install \
	  prefix=$(MPC_STAGE)/32
$(MPC_BUILD)/32/Makefile:
	rm -fR $(MPC_BUILD)/32
	mkdir -p $(MPC_BUILD)/32
	cd $(MPC_BUILD)/32 \
	&& $(MPC_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  --libdir=$$\{prefix}/lib32 \
	  CFLAGS="$(CFGS) -m32" LDFLAGS="$(LDFGS) -m32 -s"

.PHONY: mpc64
mpc64: $(MPC_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(MPC_BUILD)/64 \
	&& $(MAKE) -C $(MPC_BUILD)/64 install \
	  prefix=$(MPC_STAGE)/64
$(MPC_BUILD)/64/Makefile:
	rm -fR $(MPC_BUILD)/64
	mkdir -p $(MPC_BUILD)/64
	cd $(MPC_BUILD)/64 \
	&& $(MPC_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  CFLAGS="$(CFGS)" LDFLAGS="$(LDFGS) -s"

# PPL, we need install GMP/MPFR/MPC first, then build this
.PHONY: ppl
ppl: ppl32 ppl64
	-rm -rf $(PPL_STAGE)/x
	mkdir -p $(PPL_STAGE)/x
	# strip *.exe, *.dll
	-find $(PPL_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(PPL_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(PPL_STAGE)/64 $(PPL_STAGE)/x/$(TARGET)
	cp -a $(PPL_STAGE)/32/lib32 $(PPL_STAGE)/x/$(TARGET)/lib32
	# move 64 bin to /x
	-mv $(PPL_STAGE)/x/$(TARGET)/bin $(PPL_STAGE)/x/
	# create bin if not exist
	-mkdir -p $(PPL_STAGE)/x/bin
	# move 32/bin/*.dll to /x/bin
	-mv $(PPL_STAGE)/32/bin/*.dll $(PPL_STAGE)/x/bin/
	# move lib32/*.dll to /x/bin
	-mv $(PPL_STAGE)/x/$(TARGET)/lib32/*.dll $(PPL_STAGE)/x/bin/
	# move lib/*.dll to /x/bin
	-mv $(PPL_STAGE)/x/$(TARGET)/lib/*.dll $(PPL_STAGE)/x/bin/
	# we don't need exe
	-rm -f $(PPL_STAGE)/x/bin/*.exe
	-rm -rf $(PPL_STAGE)/32
	-rm -rf $(PPL_STAGE)/64
	-rm -rf $(PPL_STAGE)/x/$(TARGET)/share/doc
	-rm -rf $(PPL_STAGE)/x/$(TARGET)/share/man/man1
	-find $(PPL_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/ppl.tar.xz 
	cd $(PPL_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/ppl.tar.xz *

.PHONY: ppl32
ppl32: $(PPL_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(PPL_BUILD)/32 \
	&& $(MAKE) -C $(PPL_BUILD)/32 install \
	  prefix=$(PPL_STAGE)/32
$(PPL_BUILD)/32/Makefile:
	rm -fR $(PPL_BUILD)/32
	mkdir -p $(PPL_BUILD)/32
	cd $(PPL_BUILD)/32 \
	&& $(PPL_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  --disable-documentation \
	  --disable-ppl_lcdd \
	  --disable-ppl_lpsol \
	  --disable-ppl_pips \
	  --libdir=$$\{prefix}/lib32 \
	  CFLAGS="$(CFGS) -m32" CXXFLAGS="$(CFGS) -m32" LDFLAGS="$(LDFGS) -s -m32"

.PHONY: ppl64
ppl64: $(PPL_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(PPL_BUILD)/64 \
	&& $(MAKE) -C $(PPL_BUILD)/64 install \
	  prefix=$(PPL_STAGE)/64
$(PPL_BUILD)/64/Makefile:
	rm -fR $(PPL_BUILD)/64
	mkdir -p $(PPL_BUILD)/64
	cd $(PPL_BUILD)/64 \
	&& $(PPL_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  --disable-documentation \
	  --disable-ppl_lcdd \
	  --disable-ppl_lpsol \
	  --disable-ppl_pips \
	  CFLAGS="$(CFGS)" CXXFLAGS="$(CFGS)" LDFLAGS="$(LDFGS) -s"

# CLOOG, we need install GMP/MPFR/MPC/PPL first, then build this
.PHONY: cloog
cloog: cloog32 cloog64
	-rm -rf $(CLOOG_STAGE)/x
	mkdir -p $(CLOOG_STAGE)/x
	# strip *.exe, *.dll
	-find $(CLOOG_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(CLOOG_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(CLOOG_STAGE)/64 $(CLOOG_STAGE)/x/$(TARGET)
	cp -a $(CLOOG_STAGE)/32/lib32 $(CLOOG_STAGE)/x/$(TARGET)/lib32
	# move 64 bin to /x
	-mv $(CLOOG_STAGE)/x/$(TARGET)/bin $(CLOOG_STAGE)/x/
	# create bin if not exist
	-mkdir -p $(CLOOG_STAGE)/x/bin
	# move 32/bin/*.dll to /x/bin
	-mv $(CLOOG_STAGE)/32/bin/*.dll $(CLOOG_STAGE)/x/bin/
	# move lib32/*.dll to /x/bin
	-mv $(CLOOG_STAGE)/x/$(TARGET)/lib32/*.dll $(CLOOG_STAGE)/x/bin/
	# move lib/*.dll to /x/bin
	-mv $(CLOOG_STAGE)/x/$(TARGET)/lib/*.dll $(CLOOG_STAGE)/x/bin/
	# we don't need exe
	-rm -f $(CLOOG_STAGE)/x/bin/*.exe
	-rm -rf $(CLOOG_STAGE)/32
	-rm -rf $(CLOOG_STAGE)/64
	-rm -rf $(CLOOG_STAGE)/x/$(TARGET)/share/doc
	-find $(CLOOG_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/cloog.tar.xz 
	cd $(CLOOG_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/cloog.tar.xz *

.PHONY: cloog32
cloog32: $(CLOOG_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(CLOOG_BUILD)/32 \
	&& $(MAKE) -C $(CLOOG_BUILD)/32 install \
	  prefix=$(CLOOG_STAGE)/32
$(CLOOG_BUILD)/32/Makefile:
	rm -fR $(CLOOG_BUILD)/32
	mkdir -p $(CLOOG_BUILD)/32
	cd $(CLOOG_BUILD)/32 \
	&& $(CLOOG_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  --libdir=$$\{prefix}/lib32 \
	  CFLAGS="$(CFGS) -m32" CXXFLAGS="$(CFGS) -m32" LDFLAGS="$(LDFGS) -s -m32"

.PHONY: cloog64
cloog64: $(CLOOG_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(CLOOG_BUILD)/64 \
	&& $(MAKE) -C $(CLOOG_BUILD)/64 install \
	  prefix=$(CLOOG_STAGE)/64
$(CLOOG_BUILD)/64/Makefile:
	rm -fR $(CLOOG_BUILD)/64
	mkdir -p $(CLOOG_BUILD)/64
	cd $(CLOOG_BUILD)/64 \
	&& $(CLOOG_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --disable-static \
	  --enable-shared \
	  CFLAGS="$(CFGS)" CXXFLAGS="$(CFGS)" LDFLAGS="$(LDFGS) -s"

# libiconv
# we make this for static only, because if we build it to shared or both
# if might need the .dll if we create windows execute file
.PHONY: iconv
iconv: iconv32 iconv64
	-rm -rf $(ICONV_STAGE)/x
	mkdir -p $(ICONV_STAGE)/x
	# strip *.exe, *.dll
	-find $(ICONV_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(ICONV_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(ICONV_STAGE)/64 $(ICONV_STAGE)/x/$(TARGET)
	cp -a $(ICONV_STAGE)/32/lib32 $(ICONV_STAGE)/x/$(TARGET)/lib32
	-mv $(ICONV_STAGE)/32/bin $(ICONV_STAGE)/x/bin32
	-mv $(ICONV_STAGE)/x/$(TARGET)/bin $(ICONV_STAGE)/x/
	-rm -f $(ICONV_STAGE)/x/bin/*.exe
	-rm -f $(ICONV_STAGE)/x/bin32/*.exe
	-rm -rf $(ICONV_STAGE)/32
	-rm -rf $(ICONV_STAGE)/64
	-rm -rf $(ICONV_STAGE)/x/$(TARGET)/share/doc
	-find $(ICONV_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/iconv.tar.xz 
	cd $(ICONV_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/iconv.tar.xz *

.PHONY: iconv32
iconv32: $(ICONV_BUILD)/32/Makefile
	-rm -rf $(ICONV_STAGE)/32
	$(MAKE) $(JOBARG) -C $(ICONV_BUILD)/32 \
	&& $(MAKE) -C $(ICONV_BUILD)/32 install \
	  prefix=$(ICONV_STAGE)/32
$(ICONV_BUILD)/32/Makefile:
	rm -fR $(ICONV_BUILD)/32
	mkdir -p $(ICONV_BUILD)/32
	cd $(ICONV_BUILD)/32 \
	&& $(ICONV_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --host=$(TARGET) \
	  --enable-static \
	  --disable-shared \
	  --libdir=$$\{prefix}/lib32 \
	  CFLAGS="$(CFGS) -m32" LDFLAGS="$(LDFGS) -s -m32" \
	  RC="windres -F pe-i386" \
	  WINDRES="windres -F pe-i386"

.PHONY: iconv64
iconv64: $(ICONV_BUILD)/64/Makefile
	-rm -rf $(ICONV_STAGE)/64
	$(MAKE) $(JOBARG) -C $(ICONV_BUILD)/64 \
	&& $(MAKE) -C $(ICONV_BUILD)/64 install \
	  prefix=$(ICONV_STAGE)/64
$(ICONV_BUILD)/64/Makefile:
	rm -fR $(ICONV_BUILD)/64
	mkdir -p $(ICONV_BUILD)/64
	cd $(ICONV_BUILD)/64 \
	&& $(ICONV_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --host=$(TARGET) \
	  --enable-static \
	  --disable-shared \
	  CFLAGS="$(CFGS)" LDFLAGS="$(LDFGS) -s"

# pthreads, use the version in mingw64
# we make this for static only, because if we build it to shared or both
# if might need the .dll if we create windows execute file
.PHONY: pthreads
pthreads: pthreads32 pthreads64
	-rm -rf $(PTHREADS_STAGE)/x
	mkdir -p $(PTHREADS_STAGE)/x
	# strip *.exe, *.dll
	-find $(PTHREADS_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(PTHREADS_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(PTHREADS_STAGE)/64 $(PTHREADS_STAGE)/x/$(TARGET)
	cp -a $(PTHREADS_STAGE)/32/lib32 $(PTHREADS_STAGE)/x/$(TARGET)/lib32
	-mv $(PTHREADS_STAGE)/32/bin $(PTHREADS_STAGE)/x/bin32
	-mv $(PTHREADS_STAGE)/x/$(TARGET)/bin $(PTHREADS_STAGE)/x/
	-rm -rf $(PTHREADS_STAGE)/32
	-rm -rf $(PTHREADS_STAGE)/64
	-rm -rf $(PTHREADS_STAGE)/x/$(TARGET)/share/doc
	-find $(PTHREADS_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/winpthreads.tar.xz 
	cd $(PTHREADS_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/winpthreads.tar.xz *

.PHONY: pthreads32
pthreads32: $(PTHREADS_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(PTHREADS_BUILD)/32 \
	&& $(MAKE) -C $(PTHREADS_BUILD)/32 install \
	  prefix=$(PTHREADS_STAGE)/32
$(PTHREADS_BUILD)/32/Makefile:
	rm -fR $(PTHREADS_BUILD)/32
	mkdir -p $(PTHREADS_BUILD)/32
	cd $(PTHREADS_BUILD)/32 \
	&& $(PTHREADS_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --enable-static \
	  --disable-shared \
	  --libdir=$$\{prefix}/lib32 \
	  CFLAGS="$(CFGS) -m32" LDFLAGS="$(LDFGS) -s -m32" \
	  RC="windres -F pe-i386" \
	  WINDRES="windres -F pe-i386"

.PHONY: pthreads64
pthreads64: $(PTHREADS_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(PTHREADS_BUILD)/64 \
	&& $(MAKE) -C $(PTHREADS_BUILD)/64 install \
	  prefix=$(PTHREADS_STAGE)/64
$(PTHREADS_BUILD)/64/Makefile:
	rm -fR $(PTHREADS_BUILD)/64
	mkdir -p $(PTHREADS_BUILD)/64
	cd $(PTHREADS_BUILD)/64 \
	&& $(PTHREADS_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --enable-static \
	  --disable-shared \
	  CFLAGS="$(CFGS)" LDFLAGS="$(LDFGS) -s"

# gcc, 64bits, posix thread mode
.PHONY: gcc
gcc:
	$(MAKE) -f $(MKFILE) gcc_64 THREAD=posix PGO=0 BITS=64 JOB=$(JOB)

# gcc, 64bits, posix thread mode without PGO
.PHONY: gcc_posix
gcc_posix:
	$(MAKE) -f $(MKFILE) gcc_64 THREAD=posix PGO=0 BITS=64 JOB=$(JOB)

# gcc, 64bits, win32 thread mode without PGO
.PHONY: gcc_win32
gcc_win32:
	$(MAKE) -f $(MKFILE) gcc_64 THREAD=win32 PGO=0 BITS=64 JOB=$(JOB)

# gcc, 64bits, posix thread mode with PGO
.PHONY: gcc_posix_pgo
gcc_posix_pgo:
	$(MAKE) -f $(MKFILE) gcc_64 THREAD=posix PGO=1 BITS=64 JOB=$(JOB)

# gcc, 64bits, win32 thread mode with PGO
.PHONY: gcc_win32_pgo
gcc_win32_pgo:
	$(MAKE) -f $(MKFILE) gcc_64 THREAD=win32 PGO=1 BITS=64 JOB=$(JOB)

.PHONY: gcc_nobs
gcc_nobs: gcc_nobs_build
	$(MAKE) -f $(MKFILE) gcc_nobs_package THREAD=posix PGO=0 BITS=64 JOB=$(JOB)

.PHONY: gcc_nobs_package
gcc_nobs_package:
	# strip *.exe, *.dll
	-find $(GCCSTAGENOBS) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(GCCSTAGENOBS) -iname '*.a' | xargs -r strip --strip-debug
	# we don't need *.la
	-find $(GCCSTAGENOBS) -iname '*.la' | xargs -r rm -f
	# move .a files from libexec to x.y.z version lib
	-mv $(GCCSTAGENOBS)/libexec/gcc/$(TARGET)/*.*.*/*.a $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/*.*.*/
	# move files from lib to x.y.z version lib
	-mv $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/lib/* $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/*.*.*/
	# move files from lib32 to x.y.z/32 version lib
	-mv $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/lib32/* $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/*.*.*/32/
	# this should be empty now, remove it
	# we need to create junction point for this after install
	-rmdir $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/lib
	-rmdir $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/lib32
	# dll should move to bin (move 32 first)
	-mv $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/*.*.*/32/*.dll $(GCCSTAGENOBS)/bin/
	-mv $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/*.*.*/32/adalib/*.dll $(GCCSTAGENOBS)/bin/
	-mv $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/*.*.*/*.dll $(GCCSTAGENOBS)/bin/
	-mv $(GCCSTAGENOBS)/lib/gcc/$(TARGET)/*.*.*/adalib/*.dll $(GCCSTAGENOBS)/bin/
	-mv $(GCCSTAGENOBS)/lib32/gcj-*.*.*-*/*.dll $(GCCSTAGENOBS)/bin/
	-mv $(GCCSTAGENOBS)/lib32/*.dll $(GCCSTAGENOBS)/bin/
	-mv $(GCCSTAGENOBS)/lib/gcj-*.*.*-*/*.dll $(GCCSTAGENOBS)/bin/
	-mv $(GCCSTAGENOBS)/lib/*.dll $(GCCSTAGENOBS)/bin/
	-rm -f $(ARCHIVE_STAGE)/gcc_nobs$(PGOBUILD)-$(BITS)-$(THREAD).tar.xz
	cd $(GCCSTAGENOBS)/ \
	&& tar Jcvf $(ARCHIVE_STAGE)/gcc_nobs$(PGOBUILD)-$(BITS)-$(THREAD).tar.xz *

.PHONY: gcc_nobs_build
gcc_nobs_build: $(GCCBUILDNOBS)/Makefile
	$(MAKE) $(JOBARG) -C $(GCCBUILDNOBS) > $(GCCBUILDNOBS)/make.log 2>&1
	$(MAKE) $(JOBARG) -C $(GCCBUILDNOBS) install prefix=$(GCCSTAGENOBS) > $(GCCBUILDNOBS)/install.log 2>&1
$(GCCBUILDNOBS)/Makefile:
	rm -fR $(GCCBUILDNOBS)
	mkdir -p $(GCCBUILDNOBS)
	cd $(GCCBUILDNOBS) \
	&& $(GCC_SRC)/configure \
	  --build=$(TARGET) \
	  --enable-targets=all \
	  --enable-languages=c,c++ \
	  --disable-libgomp \
	  --disable-objc-gc \
	  --disable-lto \
	  --enable-graphite \
	  --enable-threads=$(THREAD) \
	  --enable-libstdcxx-time=yes \
	  --enable-cloog-backend=isl \
	  --enable-checking=release \
	  --enable-version-specific-runtime-libs \
	  --enable-fully-dynamic-string \
	  --disable-ppl-version-check \
	  --disable-cloog-version-check \
	  --disable-libstdcxx-debug \
	  --disable-libstdcxx-pch \
	  --disable-bootstrap \
	  --disable-rpath \
	  --disable-symvers \
	  --with-gnu-ld \
	  --with-gnu-as \
	  --with-libiconv \
	  --disable-werror \
	  --disable-nls \
	  --disable-win32-registry \
	  --prefix=$(GCC_PREFIX) \
	  --with-local-prefix=$(GCC_PREFIX) \
	  --with-pkgversion="$(NAME)-x86_64-$(SUB_VER)"  

.PHONY: gcc_64
gcc_64: gcc_64_build
	$(MAKE) -f $(MKFILE) gcc_64_package THREAD=$(THREAD) PGO=$(PGO) BITS=$(BITS) JOB=$(JOB)

.PHONY: gcc_64_package
gcc_64_package:
	# strip *.exe, *.dll
	-find $(GCCSTAGE64) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(GCCSTAGE64) -iname '*.a' | xargs -r strip --strip-debug
	# we don't need *.la
	-find $(GCCSTAGE64) -iname '*.la' | xargs -r rm -f
	# move .a files from libexec to x.y.z version lib
	-mv $(GCCSTAGE64)/libexec/gcc/$(TARGET)/*.*.*/*.a $(GCCSTAGE64)/lib/gcc/$(TARGET)/*.*.*/
	# move files from lib to x.y.z version lib
	-mv $(GCCSTAGE64)/lib/gcc/$(TARGET)/lib/* $(GCCSTAGE64)/lib/gcc/$(TARGET)/*.*.*/
	# move files from lib32 to x.y.z/32 version lib
	-mv $(GCCSTAGE64)/lib/gcc/$(TARGET)/lib32/* $(GCCSTAGE64)/lib/gcc/$(TARGET)/*.*.*/32/
	# this should be empty now, remove it
	# we need to create junction point for this after install
	-rmdir $(GCCSTAGE64)/lib/gcc/$(TARGET)/lib
	-rmdir $(GCCSTAGE64)/lib/gcc/$(TARGET)/lib32
	# dll should move to bin (move 32 first)
	-mv $(GCCSTAGE64)/lib/gcc/$(TARGET)/*.*.*/32/*.dll $(GCCSTAGE64)/bin/
	-mv $(GCCSTAGE64)/lib/gcc/$(TARGET)/*.*.*/32/adalib/*.dll $(GCCSTAGE64)/bin/
	-mv $(GCCSTAGE64)/lib/gcc/$(TARGET)/*.*.*/*.dll $(GCCSTAGE64)/bin/
	-mv $(GCCSTAGE64)/lib/gcc/$(TARGET)/*.*.*/adalib/*.dll $(GCCSTAGE64)/bin/
	-mv $(GCCSTAGE64)/lib32/gcj-*.*.*-*/*.dll $(GCCSTAGE64)/bin/
	-mv $(GCCSTAGE64)/lib32/*.dll $(GCCSTAGE64)/bin/
	-mv $(GCCSTAGE64)/lib/gcj-*.*.*-*/*.dll $(GCCSTAGE64)/bin/
	-mv $(GCCSTAGE64)/lib/*.dll $(GCCSTAGE64)/bin/
	-rm -f $(ARCHIVE_STAGE)/gcc$(PGOBUILD)-$(BITS)-$(THREAD).tar.xz
	cd $(GCCSTAGE64)/ \
	&& tar Jcvf $(ARCHIVE_STAGE)/gcc$(PGOBUILD)-$(BITS)-$(THREAD).tar.xz *

.PHONY: gcc_64_build
gcc_64_build: $(GCCBUILD64)/Makefile
	# sometimes, in stage2/3, can't use stdinc (why?)
	# so we need to force it to use the stdinc
	$(MAKE) $(JOBARG) -C $(GCCBUILD64) $(PGOBUILD)bootstrap \
	  BOOT_CFLAGS="$(CFGS) $(LTOFLAGS) -I$(TARGET_DIR)/include"  \
	  BOOT_LDFLAGS="$(LDFGS) -L$(TARGET_DIR)/lib -L$(GCCBUILD64)/prev-$(TARGET)/libstdc++-v3/src/.libs" > $(GCCBUILD64)/make.log 2>&1
	# install, using jobserver will lost some file for adalib
	$(MAKE) -C $(GCCBUILD64) install prefix=$(GCCSTAGE64) > $(GCCBUILD64)/install.log 2>&1
$(GCCBUILD64)/Makefile:
	rm -fR $(GCCBUILD64)
	mkdir -p $(GCCBUILD64)
	mkdir -p $(GCCBUILD64)/crt
	mkdir -p $(GCCBUILD64)/crt32
	cp $(GCC_PREFIX)/$(TARGET)/lib/crt2.o $(GCCBUILD64)/crt/
	cp $(GCC_PREFIX)/$(TARGET)/lib/crtbegin.o $(GCCBUILD64)/crt/
	cp $(GCC_PREFIX)/$(TARGET)/lib/crtend.o $(GCCBUILD64)/crt/
	cp $(GCC_PREFIX)/$(TARGET)/lib32/crt2.o $(GCCBUILD64)/crt32/
	cp $(GCC_PREFIX)/$(TARGET)/lib32/crtbegin.o $(GCCBUILD64)/crt32/
	cp $(GCC_PREFIX)/$(TARGET)/lib32/crtend.o $(GCCBUILD64)/crt32/
	cd $(GCCBUILD64) \
	&& $(GCC_SRC)/configure \
	  --build=$(TARGET) \
	  --enable-targets=all \
	  --enable-languages=c,c++,fortran,objc,obj-c++,ada,lto \
	  --enable-libgomp \
	  --enable-libada \
	  --enable-objc-gc \
	  --enable-lto \
	  --enable-graphite \
	  --enable-threads=$(THREAD) \
	  --enable-libstdcxx-time=yes \
	  --enable-cloog-backend=isl \
	  --enable-checking=release \
	  --enable-version-specific-runtime-libs \
	  --enable-fully-dynamic-string \
	  --disable-ppl-version-check \
	  --disable-cloog-version-check \
	  --disable-libstdcxx-debug \
	  --disable-libstdcxx-pch \
	  --enable-bootstrap \
	  --disable-rpath \
	  --disable-symvers \
	  --with-gnu-ld \
	  --with-gnu-as \
	  --with-libiconv \
	  --disable-werror \
	  --disable-nls \
	  --disable-win32-registry \
	  --prefix=$(GCC_PREFIX) \
	  --with-local-prefix=$(GCC_PREFIX) \
	  --with-pkgversion="$(NAME)-x86_64-$(SUB_VER)"  

# gcc, 32bits, posix thread mode without PGO
.PHONY: gcc32
gcc32:
	$(MAKE) -f $(MKFILE) gcc_32 THREAD=posix PGO=0 BITS=32 JOB=$(JOB)

# gcc, 32bits, posix thread mode without PGO
.PHONY: gcc32_posix
gcc32_posix:
	$(MAKE) -f $(MKFILE) gcc_32 THREAD=posix PGO=0 BITS=32 JOB=$(JOB)

# gcc, 32bits, win32 thread mode without PGO
.PHONY: gcc32_win32
gcc32_win32:
	$(MAKE) -f $(MKFILE) gcc_32 THREAD=win32 PGO=0 BITS=32 JOB=$(JOB)

# gcc, 32bits, posix thread mode with PGO
.PHONY: gcc32_posix_pgo
gcc32_posix_pgo:
	$(MAKE) -f $(MKFILE) gcc_32 THREAD=posix PGO=1 BITS=32 JOB=$(JOB)

# gcc, 32bits, win32 thread mode with PGO
.PHONY: gcc32_win32_pgo
gcc32_win32_pgo:
	$(MAKE) -f $(MKFILE) gcc_32 THREAD=win32 PGO=1 BITS=32 JOB=$(JOB)

.PHONY: gcc_32
gcc_32: gcc_32_build
	$(MAKE) -f $(MKFILE) gcc_32_package THREAD=$(THREAD) PGO=$(PGO) BITS=$(BITS) JOB=$(JOB)

.PHONY: gcc_32_package
gcc_32_package:
	# strip *.exe, *.dll
	-find $(GCCSTAGE32) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(GCCSTAGE32) -iname '*.a' | xargs -r strip --strip-debug
	# we don't need *.la
	-find $(GCCSTAGE32) -iname '*.la' | xargs -r rm -f
	# move .a files from libexec to x.y.z version lib/32 (this is 32bits version)
	-mv $(GCCSTAGE32)/libexec/gcc/$(TARGET)/*.*.*/*.a $(GCCSTAGE32)/lib/gcc/$(TARGET)/*.*.*/32/
	# move files from lib to x.y.z version lib
	-mv $(GCCSTAGE32)/lib/gcc/$(TARGET)/lib/* $(GCCSTAGE32)/lib/gcc/$(TARGET)/*.*.*/
	# move files from lib32 to x.y.z version lib/32
	-mv $(GCCSTAGE32)/lib/gcc/$(TARGET)/lib32/* $(GCCSTAGE32)/lib/gcc/$(TARGET)/*.*.*/32/
	# this should be empty now, remove it
	# we need to create junction point for this after install
	-rmdir $(GCCSTAGE32)/lib/gcc/$(TARGET)/lib
	-rmdir $(GCCSTAGE32)/lib/gcc/$(TARGET)/lib32
	# dll should move to bin (move 64 first)
	-mv $(GCCSTAGE32)/lib/gcc/$(TARGET)/*.*.*/*.dll $(GCCSTAGE32)/bin/
	-mv $(GCCSTAGE32)/lib/gcc/$(TARGET)/*.*.*/adalib/*.dll $(GCCSTAGE32)/bin/
	-mv $(GCCSTAGE32)/lib/gcc/$(TARGET)/*.*.*/32/*.dll $(GCCSTAGE32)/bin/
	-mv $(GCCSTAGE32)/lib/gcc/$(TARGET)/*.*.*/32/adalib/*.dll $(GCCSTAGE32)/bin/
	-mv $(GCCSTAGE32)/lib/gcj-*.*.*-*/*.dll $(GCCSTAGE32)/bin/
	-mv $(GCCSTAGE32)/lib/*.dll $(GCCSTAGE32)/bin/
	-mv $(GCCSTAGE32)/lib32/gcj-*.*.*-*/*.dll $(GCCSTAGE32)/bin/
	-mv $(GCCSTAGE32)/lib32/*.dll $(GCCSTAGE32)/bin/
	-rm -f $(ARCHIVE_STAGE)/gcc$(PGOBUILD)-$(BITS)-$(THREAD).tar.xz
	cd $(GCCSTAGE32)/ \
	&& tar Jcvf $(ARCHIVE_STAGE)/gcc$(PGOBUILD)-$(BITS)-$(THREAD).tar.xz *

.PHONY: gcc_32_build
gcc_32_build: $(GCCBUILD32)/Makefile
	# sometimes, in stage2/3, can't use stdinc and also can't find stdlib and libstdc++ (why?)
	# so we need to force it to use the stdinc/stdlib and use prev-build libstdc++ 
	$(MAKE) $(JOBARG) -C $(GCCBUILD32) $(PGOBUILD)bootstrap \
	  BOOT_CFLAGS="$(CFGS) -m32 $(LTOFLAGS32) -I$(TARGET_DIR)/include -L$(TARGET_DIR)/lib32" \
	  BOOT_LDFLAGS="$(LDFGS) -s -m32 $(LTOFLAGS32) -L$(TARGET_DIR)/lib32 -L$(GCCBUILD32)/prev-$(TARGET)/32/libstdc++-v3/src/.libs" > $(GCCBUILD32)/make.log 2>&1
	# install, using jobserver will lost some file for adalib
	$(MAKE) -C $(GCCBUILD32) install prefix=$(GCCSTAGE32) > $(GCCBUILD32)/install.log 2>&1 
$(GCCBUILD32)/Makefile:
	rm -fR $(GCCBUILD32)
	mkdir -p $(GCCBUILD32)
	mkdir -p $(GCCBUILD32)/crt
	mkdir -p $(GCCBUILD32)/crt32
	cp $(GCC_PREFIX)/$(TARGET)/lib/crt2.o $(GCCBUILD32)/crt/
	cp $(GCC_PREFIX)/$(TARGET)/lib/crtbegin.o $(GCCBUILD32)/crt/
	cp $(GCC_PREFIX)/$(TARGET)/lib/crtend.o $(GCCBUILD32)/crt/
	cp $(GCC_PREFIX)/$(TARGET)/lib32/crt2.o $(GCCBUILD32)/crt32/
	cp $(GCC_PREFIX)/$(TARGET)/lib32/crtbegin.o $(GCCBUILD32)/crt32/
	cp $(GCC_PREFIX)/$(TARGET)/lib32/crtend.o $(GCCBUILD32)/crt32/
	cd $(GCCBUILD32) \
	&& $(GCC_SRC)/configure \
	  --build=$(TARGET) \
	  --enable-targets=all \
	  --enable-languages=c,c++,fortran,objc,obj-c++,ada,lto \
	  --enable-libgomp \
	  --enable-libada \
	  --enable-objc-gc \
	  --enable-lto \
	  --enable-graphite \
	  --enable-threads=$(THREAD) \
	  --enable-libstdcxx-time=yes \
	  --enable-cloog-backend=isl \
	  --enable-checking=release \
	  --enable-version-specific-runtime-libs \
	  --enable-fully-dynamic-string \
	  --disable-ppl-version-check \
	  --disable-cloog-version-check \
	  --disable-libstdcxx-debug \
	  --disable-libstdcxx-pch \
	  --enable-bootstrap \
	  --disable-rpath \
	  --disable-symvers \
	  --with-gnu-ld \
	  --with-gnu-as \
	  --with-libiconv \
	  --disable-werror \
	  --disable-nls \
	  --disable-win32-registry \
	  --prefix=$(GCC_PREFIX) \
	  --with-local-prefix=$(GCC_PREFIX) \
	  --with-pkgversion="$(NAME)-i686-$(SUB_VER)"  

.PHONY: expat
expat: expat32 expat64
	-rm -rf $(EXPAT_STAGE)/x
	mkdir -p $(EXPAT_STAGE)/x
	# strip *.exe, *.dll
	-find $(EXPAT_STAGE) -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	-find $(EXPAT_STAGE) -iname '*.a' | xargs -r strip --strip-debug
	cp -a $(EXPAT_STAGE)/64 $(EXPAT_STAGE)/x/$(TARGET)
	cp -a $(EXPAT_STAGE)/32/lib32 $(EXPAT_STAGE)/x/$(TARGET)/lib32
	-mv $(EXPAT_STAGE)/32/bin $(EXPAT_STAGE)/x/bin32
	-mv $(EXPAT_STAGE)/x/$(TARGET)/bin $(EXPAT_STAGE)/x/
	-rm -rf $(EXPAT_STAGE)/32
	-rm -rf $(EXPAT_STAGE)/64
	-rm -rf $(EXPAT_STAGE)/x/$(TARGET)/share/doc
	-find $(EXPAT_STAGE)/x -iname '*.la' | xargs -r rm -f
	-rm -f $(ARCHIVE_STAGE)/expat.tar.xz 
	cd $(EXPAT_STAGE)/x \
	&& tar Jcvf $(ARCHIVE_STAGE)/expat.tar.xz *

.PHONY: expat32
expat32: $(EXPAT_BUILD)/32/Makefile
	$(MAKE) $(JOBARG) -C $(EXPAT_BUILD)/32 \
	&& $(MAKE) -C $(EXPAT_BUILD)/32 install \
	  prefix=$(EXPAT_STAGE)/32
$(EXPAT_BUILD)/32/Makefile:
	rm -fR $(EXPAT_BUILD)/32
	mkdir -p $(EXPAT_BUILD)/32
	cd $(EXPAT_BUILD)/32 \
	&& $(EXPAT_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --enable-static \
	  --enable-shared \
	  --libdir=$$\{prefix}/lib32 \
	  CFLAGS="$(CFGS) -m32" LDFLAGS="$(LDFGS) -m32 -s"

.PHONY: expat64
expat64: $(EXPAT_BUILD)/64/Makefile
	export CFLAGS="$(CFGS)" \
	&& $(MAKE) $(JOBARG) -C $(EXPAT_BUILD)/64 \
	&& $(MAKE) -C $(EXPAT_BUILD)/64 install \
	  prefix=$(EXPAT_STAGE)/64
$(EXPAT_BUILD)/64/Makefile:
	rm -fR $(EXPAT_BUILD)/64
	mkdir -p $(EXPAT_BUILD)/64
	cd $(EXPAT_BUILD)/64 \
	&& $(EXPAT_SRC)/configure \
	  --prefix=$(TARGET_DIR) \
	  --build=$(TARGET) \
	  --enable-static \
	  --enable-shared \
	  CFLAGS="$(CFGS)" LDFLAGS="$(LDFGS) -s"

# gdb, not test yet
.PHONY: gdb
gdb: gdb64

.PHONY: gdb64
gdb64: gdb64_build
	# strip *.exe, *.dll
	-find $(GDB_STAGE)/64 -iregex '.*\.\(exe\|dll\)' | xargs -r strip --strip-unneeded
	# we don't want include and lib
	-rm -rf $(GDB_STAGE)/64/include
	-rm -rf $(GDB_STAGE)/64/lib
	# make tarball
	-rm -f $(ARCHIVE_STAGE)/gdb_64.tar.xz
	cd $(GDB_STAGE)/64 \
	&& tar Jcvf $(ARCHIVE_STAGE)/gdb_64.tar.xz *

.PHONY: gdb64_build
gdb64_build: $(GDB_BUILD)/64/Makefile
	$(MAKE) $(JOBARG) -C $(GDB_BUILD)/64 \
	&& $(MAKE) -C $(GDB_BUILD)/64 install prefix=$(GDB_STAGE)/64
$(GDB_BUILD)/64/Makefile:
	rm -fR $(GDB_BUILD)/64
	mkdir -p $(GDB_BUILD)/64
	cd $(GDB_BUILD)/64 \
	&& $(GDB_SRC)/configure \
	  --build=$(TARGET) \
	  --prefix=$(GDB_STAGE) \
	  --disable-nls \
	  --enable-targets=$(TARGET),i686-w64-mingw32 \
	  --enable-64-bit-bfd \
	  CFLAGS="$(CFGS) -DMS_WIN64" \
	  LDFLAGS="$(LDFGS) -s"

