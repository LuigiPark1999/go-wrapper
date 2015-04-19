# go-wrapper

go-wrapper is a script that can be used to automatically add the current Go workspace to your `$GOPATH` environment variable when you invoke golang tools.

This allows you to put your code almost anywhere outside your `$GOPATH` and it will automatically be added when you run Go tools as long as there is a 'src' component in the path.


## App Engine support

If you use Go for App Engine, it will use the App Engine SDK tools if:
 * it finds them in $AE_PATH or ~/opt/go_appengine (default)
 * the current directory or any ancestor encountered before a workspace root contains a file named `app.yaml`.

If invoked as `go` it will also use `goapp` for the following subcommands:
```shell
go build
go test
go serve  # App Engine-specific
go deploy # App Engine-specific
```

App engine tools can be disabled by symlinking the script to a name with an "r" prefix (for "real"), such as "rgo" for the `go` tool and invoking it by that name.


## Requirements

go-wrapper is a shell script, so it requires bash. (I'm not sure if it works with other shells)

On most unix-like systems this should already be installed, but Windows users can get it by installing Cygwin.
It has only been tested on Linux though.

If your `$GOROOT` environment variable has been not set (or not correctly) it will try to recover by checking in ~/opt/go and /usr/local/go, but if it can't find the Go tools there it will fail. The only exception are the App Engine SDK tools, as noted above.


## Install

Just symlink (or copy) the script to the name of the command it should invoke and place it in your $PATH before the command itself.

```shell
cd ~/bin	# Or another directory on your $PATH, as long as it's before $GOROOT/bin
ln -s path/to/go-wrapper.sh go
ln -s path/to/go-wrapper.sh godoc
ln -s path/to/go-wrapper.sh goimports
# .. and similarly for any other programs that use $GOPATH
```
