# go-wrapper

go-wrapper is a script that can be used to automatically add the current go workspace to your `$GOPATH` environment variable when you invoke golang tools.

If it finds a `_vendor/src`, it adds that to the *front* of `$GOPATH`, so that `go get` should automatically put packages there. If this is undesired, there are several options:
 * invoke `go get` without using this script, as `$GOROOT/bin/go get`, or
 * edit the script to put it at the end instead., or
 * invoke `go get` from outside your workspace: `(cd ~ ; go get $PACKAGE)`

If you use Go for App Engine, it will use the App Engine SDK tools if it finds a directory named `sdk` with the App Engine SDK in it in any parent directory before it finds a `src` directory.
This can be disabled by symlinking it to a name with an "r" prefix (for "real"), such as "rgo" for the `go` tool and invoking it by that name.

## Requirements

go-wrapper is a shell script, so it requires bash. (I'm not sure if it works with other shells)

On most unix-like systems this should already be installed, but Windows users can get it by installing Cygwin.
It has only been tested on Linux though.

It also requires that your `$GOROOT` environment variable has been set correctly, because it uses that to find the real tools (unless it's found an App Engine SDK, as noted above).



## Install

Just symlink (or copy) the script to the name of the command it should invoke and place it in your $PATH before the command itself.

    cd ~/bin	# Or another directory on your $PATH, as long as it's before $GOROOT/bin
	ln -s path/to/go-wrapper.sh go
	ln -s path/to/go-wrapper.sh godoc
	ln -s path/to/go-wrapper.sh goimports
	# .. and similarly for any other programs that use $GOPATH
