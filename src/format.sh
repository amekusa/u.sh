[ -n "$_shlib_format" ] && return; readonly _shlib_format=1

##
#  shlib/format
# -------------- -
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

# Usage:
#   echo -e "${GRN}Hello World${RST}"

# Special chars
LF=$'\n'
TAB=$'\t'

# Defines ANSI code variables
_ansi() {
	ESC='\033'

	while [ $# -gt 0 ]; do
		case "$1" in
		-e|--esc)
			shift
			case "$1" in
				oct)  ESC='\033'   ;;
				hex)  ESC='\x1b'   ;;
				uni)  ESC='\u001b' ;;
				char) ESC=$'\e'    ;;  # NOTE: This enables ANSI codes without passing '-e' option to echo
				*) echo "[ERROR] _ansi: invalid argument '$1'" >&2
			esac
			;;
		-*)
			echo "[ERROR] _ansi: invalid argument '$1'" >&2
			;;
		esac
		shift
	done

	# regular           # bold               # underline          # intensified        # bold + intense      # background        # intense background
	BLK="${ESC}[0;30m"; bBLK="${ESC}[1;30m"; uBLK="${ESC}[4;30m"; iBLK="${ESC}[0;90m"; biBLK="${ESC}[1;90m"; OnBLK="${ESC}[40m"; iOnBLK="${ESC}[0;100m"
	RED="${ESC}[0;31m"; bRED="${ESC}[1;31m"; uRED="${ESC}[4;31m"; iRED="${ESC}[0;91m"; biRED="${ESC}[1;91m"; OnRED="${ESC}[41m"; iOnRED="${ESC}[0;101m"
	GRN="${ESC}[0;32m"; bGRN="${ESC}[1;32m"; uGRN="${ESC}[4;32m"; iGRN="${ESC}[0;92m"; biGRN="${ESC}[1;92m"; OnGRN="${ESC}[42m"; iOnGRN="${ESC}[0;102m"
	YLW="${ESC}[0;33m"; bYLW="${ESC}[1;33m"; uYLW="${ESC}[4;33m"; iYLW="${ESC}[0;93m"; biYLW="${ESC}[1;93m"; OnYLW="${ESC}[43m"; iOnYLW="${ESC}[0;103m"
	BLU="${ESC}[0;34m"; bBLU="${ESC}[1;34m"; uBLU="${ESC}[4;34m"; iBLU="${ESC}[0;94m"; biBLU="${ESC}[1;94m"; OnBLU="${ESC}[44m"; iOnBLU="${ESC}[0;104m"
	MAG="${ESC}[0;35m"; bMAG="${ESC}[1;35m"; uMAG="${ESC}[4;35m"; iMAG="${ESC}[0;95m"; biMAG="${ESC}[1;95m"; OnMAG="${ESC}[45m"; iOnMAG="${ESC}[0;105m"
	CYN="${ESC}[0;36m"; bCYN="${ESC}[1;36m"; uCYN="${ESC}[4;36m"; iCYN="${ESC}[0;96m"; biCYN="${ESC}[1;96m"; OnCYN="${ESC}[46m"; iOnCYN="${ESC}[0;106m"
	WHT="${ESC}[0;37m"; bWHT="${ESC}[1;37m"; uWHT="${ESC}[4;37m"; iWHT="${ESC}[0;97m"; biWHT="${ESC}[1;97m"; OnWHT="${ESC}[47m"; iOnWHT="${ESC}[0;107m"

	# colorless
	b_="${ESC}[1m" # bold
	u_="${ESC}[4m" # underline

	# reset
	RST="${ESC}[0m"
}
_ansi;

_success() {
	echo -e "[${GRN}SUCCESS${RST}] $*"
}

_error() {
	echo -e "[${RED}ERROR${RST}] $*"
}

_warn() {
	echo -e "[${YLW}WARN${RST}] $*"
}
