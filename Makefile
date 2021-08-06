.POSIX:
SHELL = /bin/sh
.SUFFIXES:

PACKAGE = jsond
DEPSFLAGS = --check-pkg-deps --unused-pkg-deps

default: setup

# Primarily for use by CI.
# Installs dependencies as well as linking this as a package.
install:
	# default with no package provided is current directory as link
	raco pkg install --deps search-auto

remove:
	raco pkg remove $(PACKAGE)

# Primarily for day-to-day dev.
# Note: Also builds docs (if any) and checks deps.
setup:
	raco setup --tidy --avoid-main $(DEPSFLAGS) --pkgs $(PACKAGE)

# Note: Each collection's info.rkt can say what to clean, for example
# (define clean '("compiled" "doc" "doc/<collect>")) to clean
# generated docs, too.
clean:
	raco setup --fast-clean --pkgs $(PACKAGE)

# Primarily for use by CI, after make install -- since that already
# does the equivalent of make setup, this tries to do as little as
# possible except checking deps.
check-deps:
	raco setup --no-docs $(DEPSFLAGS) $(PACKAGE)

try-fix-deps:
	raco setup --no-docs $(DEPSFLAGS) --fix-pkg-deps --pkgs $(PACKAGE)

# Suitable for both day-to-day dev and CI
test:
	raco test -x -p $(PACKAGE)
