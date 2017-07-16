.DEFAULT_GOAL := all

FILES :=            \
    .gitignore      \
    Collatz.c++     \
    Collatz.h       \
    Collatz.log     \
    html            \
    makefile        \
    RunCollatz.c++  \
    RunCollatz.in   \
    RunCollatz.out  \
    TestCollatz.c++ \
    TestCollatz.out \
   	.travis.yml                           
   	# collatz-tests/jtrejo13-RunCollatz.in  \
   	# collatz-tests/jtrejo13-RunCollatz.out \

ifeq ($(shell uname), Darwin)                                           # Apple
    CXX          := g++
    INCLUDE      := /usr/local/include
    CXXFLAGS     := -pedantic -std=c++14 -Wall -Weffc++
    # NEW
    CPPFLAGS     := -isystem $(INCLUDE)
    LIBB         := /usr/local/lib
    LIBG         := /usr/local/lib
    LDFLAGS      := -lboost_serialization -lgtest -lgtest_main
    CLANG-CHECK  := clang-check
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

collatz-tests:
	git clone https://github.com/cs371gt-summer-2017/collatz-tests.git

html: Doxyfile Collatz.h
	$(DOXYGEN) Doxyfile

Collatz.log:
	git log > Collatz.log

Doxyfile:
	$(DOXYGEN) -g
	# you must manually edit Doxyfile and
	# set EXTRACT_ALL     to YES
	# set EXTRACT_PRIVATE to YES
	# set EXTRACT_STATEIC to YES

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
	$(VALGRIND) ./TestCollatz                                  >  TestCollatz.tmp 2>&1
	-$(GCOV) -b Collatz.c++ | grep -A 5 "File '.*Collatz.c++'" >> TestCollatz.tmp
	cat TestCollatz.tmp

all: RunCollatz TestCollatz

check:
	@not_found=0;                                 \
    for i in $(FILES);                            \
    do                                            \
        if [ -e $$i ];                            \
        then                                      \
            echo "$$i found";                     \
        else                                      \
            echo "$$i NOT FOUND";                 \
            not_found=`expr "$$not_found" + "1"`; \
        fi                                        \
    done;                                         \
    if [ $$not_found -ne 0 ];                     \
    then                                          \
        echo "$$not_found failures";              \
        exit 1;                                   \
    fi;                                           \
    echo "success";

clean:
	rm -f  *.gcda
	rm -f  *.gcno
	rm -f  *.gcov
	rm -f  *.plist
	rm -f  *.tmp
	rm -f  RunCollatz
	rm -f  TestCollatz
	rm -rf *.dSYM
	rm -rf latex

config:
	git config -l

docker:
	sudo docker run -it -v $(PWD):/usr/cs371g -w /usr/cs371g gpdowning/gcc

format:
	$(CLANG-FORMAT) -i Collatz.c++
	$(CLANG-FORMAT) -i Collatz.h
	$(CLANG-FORMAT) -i RunCollatz.c++
	$(CLANG-FORMAT) -i TestCollatz.c++

scrub:
	make clean
	rm -f  Collatz.log
	rm -f  Doxyfile
	rm -rf collatz-tests
	rm -rf html

status:
	make clean
	@echo
	git branch
	git remote -v
	git status

test: RunCollatz.tmp TestCollatz.tmp

travis: collatz-tests html Collatz.log
	make clean
	ls -al
	make
	ls -al
	make test
	ls -al
	make check

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
	#@echo
	#which $(CLANG-CHECK)
	#-$(CLANG-CHECK) --version
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
