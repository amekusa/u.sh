##
#  ush/io
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

_ush_file() {
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
			*) echo "[ERROR] _ush_file(): invalid argument: $1"; return 1
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

_ush_dir() {
	_ush_file "$@" -d
}

_ush_symlink() {
	local force=false
	if [ "$1" = "-F" ]; then force=true; shift; fi
	local src="$1"
	local dst="$2"
	if [ ! -e "$src" ]; then
		echo "[FAIL] file not found: $src"
		return 1
	fi
	if [ -e "$dst" ]; then
		if $force; then
			if ! _ush_del "$dst"; then
				echo "[FAIL] file already exists and cannot be deleted: $dst"
				return 1
			fi
		else
			echo "[FAIL] file already exists: $dst"
			return 1
		fi
	fi
	ln -sn "$src" "$dst"
}

_ush_del() {
	[ -e "$1" ] || return 0
	if [ -d "$1" ];
		then rm -rf "$1"
		else rm "$1"
	fi
}

_ush_comment() {
	local srch="$1"; shift
	local file="$1"; shift
	local sedx="s/^([[:blank:]]*)([^#[:blank:]])/\1# \2/"
	[ -z "$srch" ] || sedx="/${srch}/ ${sedx}"
	if [ -n "$file" ]
		then sed -Ei "$sedx" "$file"
		else sed -E "$sedx"
	fi
}

_ush_uncomment() {
	local srch="$1"; shift
	local file="$1"; shift
	local sedx="s/^([[:blank:]]*)#+[[:blank:]]*/\1/"
	[ -z "$srch" ] || sedx="/${srch}/ ${sedx}"
	if [ -n "$file" ]
		then sed -Ei "$sedx" "$file"
		else sed -E "$sedx"
	fi
}

_ush_save-var() {
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

_ush_load-var() {
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

_ush_subst() {
	local pat="{{%s}}" # find pattern
	local sep="="      # key-value separator
	local arg key value find sedx
	while [ $# -gt 0 ]; do
		case "$1" in
			-p) pat="$2"; shift ;;
			-s) sep="$2"; shift ;;
			*${sep}*)
				arg="$1"
				key="${arg%%${sep}*}"
				value="${arg:$((${#key}+1))}"
				find="$(printf "$pat" "$key")"
				sedx="${sedx}s|$find|$value|g;"
		esac
		shift
	done
	sed "$sedx"
}

# insert/update a section in a file
_ush_section() {
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
