#!/bin/bash
# Add the innermost enclosing directory containing a src/ subdir
# with .go files in it to GOPATH.
#
# Figure out $GOROOT from a set of defaults if not set correctly already.
#
# Then run the program with the same name from $GOROOT/bin
# Unless we're running in an appengine path, then we run $APPENGINE/$0
#
# License: See the comment at the end of the file.

# The name of the program to find and run.
name="$(basename "$0")"

# If the name starts with 'r' (for real), ignore App Engine.
allow_ae=1
if [ "${name:0:1}" = "r" ]; then
	name="${name:1}"
	allow_ae=0
fi

# Ditto if App Engine tools can't be found.
AE_PATH="${AE_PATH:-$HOME/opt/go_appengine}" # Get a default if not set.
if [ ! -x "$AE_PATH/goapp" ]; then
	allow_ae=0
fi

# Find $GOROOT if not set (correctly)
for dir in "$GOROOT" ~/opt/go /usr/local/go; do
	if [ -x "$dir/bin/go" ]; then
		export GOROOT="$dir"
		break
	fi
done

# Find the program to run
real_prog="$GOROOT/bin/$name"
if [ ! -x "$real_prog" - a -x "$AE_PATH/$name" ]; then
	# Last hope: use App Engine equivalent.
	real_prog="$AE_PATH/$name"
elif [ ! -f "$real_prog" ]; then
	echo "Can't run $real_prog: does not exist" >2
	exit 1
elif [ ! -x "$real_prog" ]; then
	echo "Can't run $real_prog: not executable" >2
	exit 2
fi
args=("$@")


dir="$(pwd)"
while [ "$dir" != / -a "$dir" != "$HOME" ]; do
	# If enabled, check for App Engine.
	if [ "$allow_ae" = "1" -a -f "$dir/app.yaml" ]; then
		# App engine path
		ae_prog="$AE_PATH/$name"
		if [ -x "$ae_prog" ]; then
			real_prog="$ae_prog"
		fi
		# Add App Engine's goroot directory to $GOPATH, don't set $GOROOT to it.
		# This still allows non-App Engine tools to find the sources for "appengine" packages.
		export "GOPATH=${GOPATH:+$GOPATH:}$AE_PATH/goroot"

		# Special-case a few specific programs.
		if [ "$name" = go ]; then
			case "${args[0]}" in
				build|test|serve|deploy)
					real_prog="$AE_PATH/goapp"
			esac
		elif [ "$name" = errcheck ]; then
			args=(-tags=appengine "$args")
		fi
		# Stop looking for app.yaml
		allow_ae=0
	fi

	# Check if there's a src dir containing *.go files here
	if [ -d "$dir/src" ] && find -L "$dir/src" -maxdepth 10 -name '*.go' -print -quit | grep . --quiet; then

		# Add to $GOPATH if not already in $GOROOT or $GOPATH
		if [[ ":$GOROOT:$GOPATH:" != *":$dir:"* ]]; then
			#~ echo "Adding $dir to \$GOPATH"
			export "GOPATH=${GOPATH:+$GOPATH:}$dir"
		fi

		break
	fi

	dir="$(dirname "$dir")"
done

#~ echo "\$GOPATH=$GOPATH"
exec "$real_prog" "${args[@]}"


# Copyright (c) 2015 Frits van Bommel
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
