#!/bin/bash
# Add the innermost enclosing directory containing a src/ subdir
# with .go files in it to GOPATH.
#
# Do the same for _vendor/src dirs.
#
# Then run the program with the same name from $GOROOT/bin
# Unless we're running in an appengine path, then we run $APPENGINE/$0
#
# License: See the comment at the end of the file.


# If the name starts with 'r' (for real), ignore app engine.
name="$(basename "$0")"
if [ "${name:0:1}" = "r" ]; then
	name="${name:1}"
fi

real_prog="$GOROOT/bin/$(basename "$name")"

if [ "$AE_PATH" = "" ]; then
	AE_PATH=~/opt/google_appengine
fi

if [ ! -f "$real_prog" ]; then
	echo "Can't run $real_prog: does not exist" >2
	exit 1
elif [ ! -x "$real_prog" ]; then
	echo "Can't run $real_prog: not executable" >2
	exit 2
fi

last=0

dir="$(pwd)"
while [ "$dir" != / -a "$dir" != "$HOME" ]; do
	# Unless the invoked name starts with 'r', check for App Engine SDK.
	if [ "${0:0:1}" != "r" ]; then
		if [ -f "$dir/app.yaml" ]; then
			# App engine path
			if [ "$name" = "go" ]; then
				name="goapp"
			fi
			ae_prog="$AE_PATH/$name"
			if [ -x "$ae_prog" ]; then
				real_prog="$ae_prog"
				export "GOPATH=$GOPATH:$AE_PATH/goroot"
				export "GOPATH=$GOPATH:$dir" # Doesn't work otherwise: no src/ dir...
				last=1
			fi
		fi
	fi

	# Check if there's a src dir containing *.go files here
	if [ -d "$dir/src" ] && find -L "$dir/src" -maxdepth 10 -name '*.go' -print -quit | grep . --quiet; then

		# Skip _vendor/src, let below code handle that
		if [[ "$dir" != */_vendor ]]; then

			# Add to $GOPATH if not already in $GOROOT or $GOPATH
			if [[ ":$GOROOT:$GOPATH:" != *":$dir:"* ]]; then
				#~ echo "Adding $dir to \$GOPATH"
				export "GOPATH=$GOPATH:$dir"
			fi

			last=1
		fi
	fi

	# Check if there's a _vendor/src dir containing *.go files here
	if [ -d "$dir/_vendor/src" ] && find -L "$dir/_vendor/src" -maxdepth 10 -name '*.go' -print -quit | grep . --quiet; then

		# Add to the front of $GOPATH even if already in $GOROOT or $GOPATH
		# This should make sure "go get" puts packages here.
		#~ echo "Adding $dir to \$GOPATH"
		export "GOPATH=$dir/_vendor:$GOPATH"
	fi

	# Stop after the first directory containing a go workspace or _vendor path.
	if [ $last = 1 ]; then
		break
	fi

	dir=$(dirname "$dir")
done
#~ echo "\$GOPATH=$GOPATH"
exec "$real_prog" "$@"


# Copyright (c) 2014 Frits van Bommel
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