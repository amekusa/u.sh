##
#  shlib/util
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

_shlib_die() {
	[ -z "$*" ] || echo "[ERROR] $*" >&2
	exit 1
}

_shlib_q() {
	"$@" &> /dev/null
}

_shlib_if() {
	local eval=false
	case "$1" in
		-e|--eval) eval=true; shift ;;
	esac

	local t f mode
	local cond=("$1")
	while shift; do
		case "$1" in
		'?')
			t="$2"
			[ "$3" = ":" ] && f="$4"
			mode=1; break
			;;
		'?:')
			f="$2"
			mode=2; break
			;;
		esac
		cond+=("$1")
	done
	if [ -z "$mode" ]; then
		cat <<- EOF >&2
		[ERROR] _shlib_if(): syntax error
		  _shlib_if [options] <condition> ? <A> : <B>
		  _shlib_if [options] <A> ?: <B>

		  Options:
		    -e, --eval :  Use 'eval' for <condition>

		EOF
		return 1
	fi
	case "$mode" in
	1)
		if $eval
			then eval "${cond[*]}" &> /dev/null
			else "${cond[@]}" &> /dev/null
		fi
		;;
	2)
		if $eval
			then t="$(eval "${cond[*]}")"
			else t="$("${cond[@]}")"
		fi
		;;
	esac
	if [ "$?" -eq 0 ]
		then echo "$t"
		else echo "$f"
	fi
}

_shlib_has-cmd() {
	command -v "$*" &> /dev/null
}

_shlib_fb() {
	local arg
	for arg in "$@"; do
		if [ -n "$arg" ]; then
			echo "$arg"
			return
		fi
	done
	return 1
}

_shlib_fb-cmd() {
	local full=false
	case "$1" in
		-f|--full) full=true; shift ;;
	esac
	local arg found
	for arg in "$@"; do
		found="$(which "$arg")" || continue
		if $full
			then echo "$found"
			else echo "$arg"
		fi
		return
	done
	return 1
}

_shlib_chk-user() {
	[ "$(whoami)" = "$1" ] || _shlib_die "run as $1"
}

_shlib_chk-cmd() {
	local arg
	for arg in "$@"; do
		_shlib_has-cmd "$arg" || _shlib_die "command '$arg' is not found"
	done
}

_shlib_join() {
	local sep="$1"; shift
	local first="$1"; shift
	printf "%s" "$first" "${@/#/$sep}"
}

_shlib_rpt() {
	local eval=false
	case "$1" in
		-e|--eval) eval=true; shift ;;
	esac

	local cmd="$1"; shift

	case "$1" in
		-w|--with) shift ;;
		*)
			cat <<- EOF >&2
			[ERROR] _shlib_rpt: syntax error
			  _shlib_rpt <command> --with <list>
			  _shlib_rpt --eval <command> --with <list>

			  Options:
			    -e, --eval :  Use 'eval' for <command>
			    -w, --with :  Specify <list> to iterate over

			EOF
			return 1
	esac

	local each
	if $eval; then
		for each in "$@"; do
			eval "$(printf "$cmd" "$each")"
		done
	else
		for each in "$@"; do
			$(printf "$cmd" "$each")
		done
	fi
}

_shlib_in() {
	local needle="$1"; shift
	local each
	for each in "$@"; do
		[ "$needle" = "$each" ] && return 0
	done
	return 1
}

_shlib_lower() {
	if [ $# -eq 0 ]
		then tr '[A-Z]' '[a-z]'
		else echo "$*" | tr '[A-Z]' '[a-z]'
	fi
}

_shlib_upper() {
	if [ $# -eq 0 ]
		then tr '[a-z]' '[A-Z]'
		else echo "$*" | tr '[a-z]' '[A-Z]'
	fi
}
