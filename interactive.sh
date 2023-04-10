[ -n "$_shlib_interactive" ] && return; readonly _shlib_interactive=1

##
#  shlib/interactive
# ------------------- -
#  author: Satoshi Soma (https://amekusa.com)
# ============================================ *
#
#  MIT License
#
#  Copyright (c) 2022 Satoshi Soma
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.
#
##

[ -z "$_SAVED_DIRS" ] && export _SAVED_DIRS=()


# ---- functions ----

# reload the login shell
reload() {
	echo "Reloading the login shell ($SHELL)..."
	exec "$SHELL" --login
}

# save dir
sd() {
	if [ "$1" = "-h" ]; then
		cat <<- EOF
		Usage:
		  $0            :  Save the current dir
		  $0 <dir>      :  Save the specified dir
		  $0 -l, --list :  List the saved dirs

		EOF
		return 1
	fi
	local dir
	local each
	if [ -z "$1" ]; then
		dir="$(pwd -L)"
	else
		case "$1" in
		-l|--list)
			local i=0
			for each in "${_SAVED_DIRS[@]}"; do
				echo "$i. $each"
				((i++))
			done
			return
			;;
		/*|~*)
			dir="$1"
			;;
		*)
			dir="$(pwd -L)/$1"
		esac
	fi
	[ "$dir" = "/" ] || dir="${dir%/}" # remove trailing slash
	[ -n "$dir" ] || return

	local save=()
	for each in "${_SAVED_DIRS[@]}"; do
		[ "$each" = "$dir" ] || save+=("$each")
	done
	save+=("$dir")

	# if the number of saves >= 10, remove the first entry
	while [ "${#save}" -gt 10 ]; do
		save=("${save[@]:1}")
	done

	_SAVED_DIRS=("${save[@]}")
}

# cd & sd
scd() {
	cd $* && sd
}

# go to saved dir
wd() {
	if [ "$1" = "-h" ]; then
		cat <<- EOF
		Usage:
		  $0          :  List the saved dirs
		  $0 -        :  Go to the last saved dir
		  $0 <index>  :  Go to the saved dir specified by the index
		  $0 <string> :  Go to the saved dir including the string

		EOF
		return 1
	fi
	if [ -z "$1" ]; then
		sd -l
		return
	fi
	if [ -z "$_SAVED_DIRS" ]; then
		echo "[ERROR] no saved dir"
		return 1
	fi
	local dir
	case "$1" in
	-)
		# the last index
		dir="${_SAVED_DIRS[@]:(${#_SAVED_DIRS}-1):1}"
		;;
	[0-9])
		# index
		dir="${_SAVED_DIRS[@]:$1:1}"
		;;
	*)
		# string match
		local each
		for each in "${_SAVED_DIRS[@]}"; do
			if [[ "$each" = *"$1"* ]]; then
				dir="$each"
				break
			fi
		done
	esac
	if [ -z "$dir" ]; then
		echo "[ERROR] directory not found"
		return 1
	fi
	cd "$dir"
}

# mkdir & cd
mkcd() {
	if [ -z "$1" ] || [ "$1" = "-h" ]; then
		cat <<- EOF
		Usage:
		  $0 <new-dir>

		EOF
		return 1
	fi
	if [ -d "$1" ]; then
		echo "dir '$1' already exists"
		cd -- "$1"
		return
	fi
	mkdir -p -- "$1" &&
	cd -- "$1"
}

# find
f() {
	if [ -z "$1" ] || [ "$1" = "-h" ]; then
		cat <<- EOF
		Usage:
		  $0 <query> [basedir] [maxdepth]

		EOF
		return 1
	fi
	local dir='.'; [ -z "$2" ] || dir="$2"
	local depth=2; [ -z "$3" ] || depth="$3"
	find "$dir" -maxdepth "$depth" -iname "*${1}*"
}

# find & cd
fcd() {
	if [ -z "$1" ] || [ "$1" = "-h" ]; then
		cat <<- EOF
		Usage:
		  $0 <query> [basedir] [maxdepth]

		EOF
		return 1
	fi
	local dir='.'; [ -z "$2" ] || dir="$2"
	local depth=2; [ -z "$3" ] || depth="$3"
	local dest=$(find "$dir" -maxdepth "$depth" -type d -iname "*${1}*" -print -quit)
	if [ -z $dest ]; then
		echo "'${1}' is not found"
		return 1
	fi
	cd "$dest"
}

# site health checker
http() {
	if [ -z "$1" ] || [ "$1" = "-h" ]; then
		cat <<- EOF
		Usage:
		  $0 <location>
		  $0 <location> -s (for HTTPS)

		EOF
		return 1
	fi
	local protocol=http
	[ "$2" = "-s" ] && protocol=https
	local ua="Site Health Check"
	local r=$(curl -Is -A "$ua" -o /dev/null -w '%{http_code} (%{time_total}s)\n' "$protocol://$1")
	echo "$r"
	local s="${r:0:3}"
	[ "$s" -ge 200 ] && [ "$s" -lt 400 ]
}

# site health checker (HTTPS)
https() {
	if [ -z "$1" ] || [ "$1" = "-h" ]; then
		cat <<- EOF
		Usage:
		  $0 <location>

		EOF
		return 1
	fi
	http "$1" -s
}
