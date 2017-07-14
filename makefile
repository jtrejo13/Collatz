.DEFAULT_GOAL := all

ifeq ($(shell uname), Darwin)                                           # Apple
    CXX          := g++
    INCLUDE      := /usr/local/include
    GTEST_DIR	 := /usr/local
    CXXFLAGS     := -pedantic -std=c++14 -Wall -Weffc++
    # NEW
    CPPFLAGS     := -isystem $(GTEST_DIR)/include
    LIBB         := /usr/local/lib
    LIBG         := /usr/local/lib
    LDFLAGS      := -lboost_serialization -lgtest -lgtest_main -L/usr/local/lib
    CLANG-CHECK  := /usr/local/Cellar/llvm/4.0.1/bin/clang-check
    GCOV         := gcov
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format
else ifeq ($(CI), true)                                                 # Travis CI
    CXX          := g++-5
    INCLUDE      := /usr/include
    CXXFLAGS     := -pedantic -std=c++14 -Wall -Weffc++
    LIBB         := /usr/lib
    LIBG         := $(PWD)/gtest
    LDFLAGS      := -lboost_serialization -lgtest -lgtest_main -pthread
    CLANG-CHECK  := clang-check
    GCOV         := gcov-5
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format
else ifeq ($(shell uname -p), unknown)                                  # Docker
    CXX          := g++
    INCLUDE      := /usr/include
    CXXFLAGS     := -pedantic -std=c++14 -Wall -Weffc++
    LIBB         := /usr/lib
    LIBG         := /usr/lib
    LDFLAGS      := -lboost_serialization -lgtest -lgtest_main -pthread
    CLANG-CHECK  := clang-check
    GCOV         := gcov
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format-3.5
else                                                                    # UTCS
    CXX          := g++
    INCLUDE      := /usr/include
    CXXFLAGS     := -pedantic -std=c++14 -Wall -Weffc++
    LIBB         := /usr/lib/x86_64-linux-gnu
    LIBG         := /usr/local/lib
    LDFLAGS      := -lboost_serialization -lgtest -lgtest_main -pthread
    CLANG-CHECK  := clang-check
    GCOV         := gcov
    GCOVFLAGS    := -fprofile-arcs -ftest-coverage
    VALGRIND     := valgrind
    DOXYGEN      := doxygen
    CLANG-FORMAT := clang-format-3.8
endif

RunCollatz: Collatz.h Collatz.c++ RunCollatz.c++
	$(CXX) $(CXXFLAGS) Collatz.c++ RunCollatz.c++ -o RunCollatz
	-$(CLANG-CHECK) -extra-arg=-std=c++11          Collatz.c++     --
	-$(CLANG-CHECK) -extra-arg=-std=c++11 -analyze Collatz.c++     --
	-$(CLANG-CHECK) -extra-arg=-std=c++11          RunCollatz.c++  --
	-$(CLANG-CHECK) -extra-arg=-std=c++11 -analyze RunCollatz.c++  --

RunCollatz.tmp: RunCollatz
	./RunCollatz < RunCollatz.in > RunCollatz.tmp
	-diff RunCollatz.tmp RunCollatz.out

TestCollatz: Collatz.h Collatz.c++ TestCollatz.c++
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(GCOVFLAGS) Collatz.c++ TestCollatz.c++ -o TestCollatz $(LDFLAGS)
	-$(CLANG-CHECK) -extra-arg=-std=c++11          TestCollatz.c++ --
	-$(CLANG-CHECK) -extra-arg=-std=c++11 -analyze TestCollatz.c++ --

TestCollatz.tmp: TestCollatz
	$(VALGRIND) ./TestCollatz                                >  TestCollatz.tmp 2>&1
	-$(GCOV) -b Collatz.c++ | grep -A 5 "File 'Collatz.c++'" >> TestCollatz.tmp
	cat TestCollatz.tmp

all: RunCollatz TestCollatz

clean:
	rm -f  *.gcda
	rm -f  *.gcno
	rm -f  *.gcov
	rm -f  *.plist
	rm -f  *.tmp
	rm -f  RunCollatz
	rm -f  TestCollatz
	rm -rf *.dSYM

sync:
	make clean
	@echo `pwd`
	@rsync -r -t -u -v --delete \
    --include "*.c++"           \
    --include "*.h"             \
    --include "*.in"            \
    --include "*.out"           \
    --include "makefile"        \
    --exclude "*"               \
    . downing@$(CS):cs/projects/c++/collatz/

test: RunCollatz.tmp TestCollatz.tmp

versions:
	which cmake
	cmake --version
	@echo
	which make
	make --version
	@echo
	which git
	git --version
	@echo
	which $(CXX)
	$(CXX) --version
	@echo
	ls -ald $(INCLUDE)/boost
	@echo
	ls -ald $(INCLUDE)/gtest
	@echo
	ls -al $(LIBB)/*boost*
	@echo
	ls -al $(LIBG)/*gtest*
	@echo
	which $(CLANG-CHECK)
	-$(CLANG-CHECK) --version
	@echo
	which $(GCOV)
	$(GCOV) --version
	@echo
	which $(VALGRIND)
	$(VALGRIND) --version
	@echo
	which $(DOXYGEN)
	$(DOXYGEN) --version
	@echo
	which $(CLANG-FORMAT)
	-$(CLANG-FORMAT) --version