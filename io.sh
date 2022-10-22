##
#  shlib/io
# ------------ -
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

_file() {
	local path="$1"; shift
	local dir=false
	local realpath=false
	local basename=false
	local mod own
	while [ -n "$1" ]; do
		case "$1" in
			-d|--dir) dir=true ;;
			-r|--realpath) realpath=true ;;
			-b|--basename) basename=true ;;
			-m|--mod) mod="$2"; shift ;;
			-o|--own) own="$2"; shift ;;
			*) echo "[ERROR] _file(): invalid argument: $1"; return 1
		esac
		shift
	done
	if $dir
		then [ -d "$path" ] || mkdir "$path" || return 1
		else [ -f "$path" ] || touch "$path" || return 1
	fi
	[ -z "$mod" ] || chmod "$mod" "$path" || return 2
	[ -z "$own" ] || chown "$own" "$path" || return 2
	local r="$path"
	$realpath && r="$(realpath "$r")"
	$basename && r="$(basename "$r")"
	echo "$r"
}

_dir() {
	_file "$@" -d
}

_uncomment() {
	local search="$1"; shift
	local file="$1"; shift
	local expr="/${search}/ s/^#+\s*//"
	if [ -n "$file" ]
		then sed -ri "$expr" "$file"
		else sed -r "$expr"
	fi
}

_save-var() {
	local key="$1"; shift
	local value="$1"; shift
	local file="$1"; shift
	[ -f "$file" ] || touch "$file"
	local temp="$(mktemp)"
	local find="^([[:space:]]*)$key="
	local found=false
	local line
	while IFS= read -r line; do
		if [[ $line =~ $find ]]; then
			line="${BASH_REMATCH[1]}$key=$value"
			found=true
		fi
		echo "$line" >> "$temp"
	done < "$file"
	$found || echo "$key=$value" >> "$temp"
	cat "$temp" > "$file"
	rm "$temp"
}

_load-var() {
	local key="$1"; shift
	local file="$1"; shift
	local find="^[[:space:]]*$key=\"?([^\"]*)\"?"
	local line
	while IFS= read -r line; do
		if [[ $line =~ $find ]]; then
			echo "${BASH_REMATCH[1]}"
			return
		fi
	done < "$file"
	return 1
}

# insert/update a section in a file
_section() {
	local name="$1"; shift # section name
	local file="$1"; shift # file to write
	local ins="$(cat)"     # content to insert (stdin)
	local temp="$(mktemp)"
	local start="# [$name:START]" # section start marker
	local end="# [$name:END]"     # section end marker
	local ctx=0 # context
	local line
	while IFS= read -r line; do
		case $ctx in
		0) # before the section
			echo "$line" >> "$temp"
			[ "$line" = "$start" ] || continue
			echo "$ins" >> "$temp"
			ctx=1
			;;
		1) # in the section
			[ "$line" = "$end" ] || continue
			echo "$line" >> "$temp"
			ctx=2
			;;
		2) # after the section
			echo "$line" >> "$temp"
			;;
		esac
	done < "$file"

	case $ctx in
	0) # section not found
		echo >> "$temp"
		echo "$start" >> "$temp"
		echo "$ins" >> "$temp"
		echo "$end" >> "$temp"
		;;
	1) # end marker missing
		echo "$end" >> "$temp"
		;;
	esac

	cat "$temp" > "$file"
	rm "$temp"
}
