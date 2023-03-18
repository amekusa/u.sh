[ -n "$_shlib_task" ] && return; readonly _shlib_task=1

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

_shlib_base="$(dirname "${BASH_SOURCE[0]}")"
. "$_shlib_base/util.sh"
. "$_shlib_base/io.sh"

_task_save_to=""
_task_exec="ALL"
_task_opt_list=false
_task_opt_force=false
_task_opt_prompt=false
_task_current=""

# Initialize task system
task-system() {
	while [ $# -gt 0 ]; do
		case "$1" in
		-s|--save-to)
			[ -z "$_task_save_to" ] || _die "task save file already specified"
			_task_save_to="$2"; shift
			[ -f "$_task_save_to" ] || touch "$_task_save_to"
			;;
		-l|--list)
			_task_opt_list=true
			;;
		-F|--force)
			_task_opt_force=true
			;;
		-p|--prompt)
			_task_opt_prompt=true
			;;
		-*)
			echo "invalid argument '$1'"
			;;
		*) # task selection
			[ "$_task_exec" = "ALL" ] && _task_exec=()
			_task_exec+=("$1")
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
	if [ "$_task_exec" != "ALL" ]; then
		_in "$task" "${_task_exec[@]}" || return 1
	fi

	# list mode
	if $_task_opt_list; then
		local status="$(task-status "$task")"
		if [ -z "$status" ];
			then echo "$task"
			else echo "$task (status: $status)"
		fi
		return 1
	fi

	# check if the previous task finished
	[ -z "$_task_current" ] || _die "the task:$_task_current is not done yet"

	# check task status
	if ! $_task_opt_force; then
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
	if $_task_opt_prompt; then
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
	_task_current="$task"
}

# Sets the current task status to DONE
ksat() {
	[ -n "$_task_current" ] || _die "no active task"
	_save-var "$_task_current" DONE "$_task_save_to" || _die "failed to write: $_task_save_to"
	echo "TASK: $_task_current > DONE"
	_task_current=""
}

fail() {
	echo "TASK: $_task_current > ERROR!"
	[ -z "$*" ] || echo " > $*"
	_save-var "$_task_current" FAILED "$_task_save_to"
	exit 1
}

# Returns task status
task-status() {
	_load-var "$1" "$_task_save_to"
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
	_save-var "$task" "$status" "$_task_save_to" || _die "failed to write: $_task_save_to"
}

reset-task() {
	set-task "$1" RESET
}

reset-tasks() {
	echo "" > "$_task_save_to"
}
