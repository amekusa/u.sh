[ -n "$_SHLIB_task" ] && return; readonly _SHLIB_task=1

##
#  shlib/task
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

_SHLIB_BASE="$(dirname "${BASH_SOURCE[0]}")"
. "$_SHLIB_BASE/util.sh"
. "$_SHLIB_BASE/io.sh"

_TASK_SAVE_TO=""
_TASK_EXEC="ALL"
_TASK_OPT_LIST=false
_TASK_OPT_FORCE=false
_TASK_OPT_PROMPT=false
_TASK_CURRENT=""

# Initialize task system
task-system() {
	while [ $# -gt 0 ]; do
		case "$1" in
		-s|--save-to)
			[ -z "$_TASK_SAVE_TO" ] || _die "task save file already specified"
			_TASK_SAVE_TO="$2"; shift
			[ -f "$_TASK_SAVE_TO" ] || touch "$_TASK_SAVE_TO"
			;;
		-l|--list)
			_TASK_OPT_LIST=true
			;;
		-F|--force)
			_TASK_OPT_FORCE=true
			;;
		-p|--prompt)
			_TASK_OPT_PROMPT=true
			;;
		-*)
			echo "invalid argument '$1'"
			;;
		*) # task selection
			[ "$_TASK_EXEC" = "ALL" ] && _TASK_EXEC=()
			_TASK_EXEC+=("$1")
			;;
		esac
		shift
	done
}

##
# Use this function to define a task
#
# Usage:
#   if task TASK_NAME; then
#   	# do stuff
#   ksat; fi
#
task() {
	local task="$1"; shift
	[ -n "$task" ] || _die "argument missing"

	# selective tasks
	if [ "$_TASK_EXEC" != "ALL" ]; then
		_in "$task" "${_TASK_EXEC[@]}" || return 1
	fi

	# list mode
	if $_TASK_OPT_LIST; then
		local status="$(task-status "$task")"
		if [ -z "$status" ];
			then echo "$task"
			else echo "$task (status: $status)"
		fi
		return 1
	fi

	# check if the previous task finished
	[ -z "$_TASK_CURRENT" ] || _die "the task:$_TASK_CURRENT is not done yet"

	# check task status
	if ! $_TASK_OPT_FORCE; then
		is-task "$task" DONE NEVER && return 1
	fi

	# check dependencies
	if [ "$1" = "-d" ]; then shift
		local arg
		for arg in "$@"; do
			is-task "$arg" DONE || return 1
		done
	fi

	# prompt
	if $_TASK_OPT_PROMPT; then
		local answer
		while true; do
			echo "Run task:$task ?"
			read -n 1 -p "[ (R)un / (S)kip / (N)ever / (D)one already ] " answer; echo
			case "$answer" in
			[Rr]) echo "> Run";          break ;;
			[Ss]) echo "> Skip";         return 1 ;;
			[Nn]) echo "> Never";        set-task "$task" NEVER; return 1 ;;
			[Dd]) echo "> Done already"; set-task "$task" DONE;  return 1 ;;
			esac
		done
	fi

	echo
	echo "TASK: $task ..."
	_TASK_CURRENT="$task"
}

# Sets the current task status to DONE
ksat() {
	[ -n "$_TASK_CURRENT" ] || _die "no active task"
	_save-var "$_TASK_CURRENT" DONE "$_TASK_SAVE_TO" || _die "failed to write: $_TASK_SAVE_TO"
	echo "TASK: $_TASK_CURRENT > DONE"
	_TASK_CURRENT=""
}

task-fail() {
	echo "TASK: $_TASK_CURRENT > ERROR!"
	[ -z "$*" ] || echo " > $*"
	_save-var "$_TASK_CURRENT" FAILED "$_TASK_SAVE_TO"
	exit 1
}

# Returns task status
task-status() {
	_load-var "$1" "$_TASK_SAVE_TO"
}

# Checks task status
is-task() {
	local status="$(task-status "$1")"; shift
	_in "$status" "$@"
}

# Sets task status
set-task() {
	local task="$1"
	local status="$2"
	_save-var "$task" "$status" "$_TASK_SAVE_TO" || _die "failed to write: $_TASK_SAVE_TO"
}

reset-task() {
	set-task "$1" RESET
}

reset-tasks() {
	echo "" > "$_TASK_SAVE_TO"
}
