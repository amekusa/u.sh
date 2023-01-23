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

# usage:
# $ echo -e "${GRN}Hello World${RST}"

# escape sequence
ESC="\033["
# ESC="\x1b["
# ESC="\e["

# regular           # bold               # underline          # intensified        # bold + intense      # background         # background + intense
BLK="${ESC}0;30m";  BBLK="${ESC}1;30m";  UBLK="${ESC}4;30m";  IBLK="${ESC}0;90m";  BIBLK="${ESC}1;90m";  ON_BLK="${ESC}40m";  ON_IBLK="${ESC}0;100m"
RED="${ESC}0;31m";  BRED="${ESC}1;31m";  URED="${ESC}4;31m";  IRED="${ESC}0;91m";  BIRED="${ESC}1;91m";  ON_RED="${ESC}41m";  ON_IRED="${ESC}0;101m"
GRN="${ESC}0;32m";  BGRN="${ESC}1;32m";  UGRN="${ESC}4;32m";  IGRN="${ESC}0;92m";  BIGRN="${ESC}1;92m";  ON_GRN="${ESC}42m";  ON_IGRN="${ESC}0;102m"
YLW="${ESC}0;33m";  BYLW="${ESC}1;33m";  UYLW="${ESC}4;33m";  IYLW="${ESC}0;93m";  BIYLW="${ESC}1;93m";  ON_YLW="${ESC}43m";  ON_IYLW="${ESC}0;103m"
BLU="${ESC}0;34m";  BBLU="${ESC}1;34m";  UBLU="${ESC}4;34m";  IBLU="${ESC}0;94m";  BIBLU="${ESC}1;94m";  ON_BLU="${ESC}44m";  ON_IBLU="${ESC}0;104m"
MAG="${ESC}0;35m";  BMAG="${ESC}1;35m";  UMAG="${ESC}4;35m";  IMAG="${ESC}0;95m";  BIMAG="${ESC}1;95m";  ON_MAG="${ESC}45m";  ON_IMAG="${ESC}0;105m"
CYN="${ESC}0;36m";  BCYN="${ESC}1;36m";  UCYN="${ESC}4;36m";  ICYN="${ESC}0;96m";  BICYN="${ESC}1;96m";  ON_CYN="${ESC}46m";  ON_ICYN="${ESC}0;106m"
WHT="${ESC}0;37m";  BWHT="${ESC}1;37m";  UWHT="${ESC}4;37m";  IWHT="${ESC}0;97m";  BIWHT="${ESC}1;97m";  ON_WHT="${ESC}47m";  ON_IWHT="${ESC}0;107m"

# colorless
B_="${ESC}1m" # bold
U_="${ESC}4m" # underline

# reset
RST="${ESC}0m"

# special chars
LF=$'\n'
TAB=$'\t'
