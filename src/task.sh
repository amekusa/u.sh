##
#  U.SH - Task System
# -------------------- -
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
##

@ush-load util io

_task_save_to=""
_task_exec="ALL"
_task_opt_list=false
_task_opt_force=false
_task_opt_prompt=false
_task_current=""
_task_repeat=false

# Initialize task system
_ush_task-system() {
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
		--reset)
			_ush_reset-tasks
			;;
		-*)
			echo "invalid argument '$1'"
			;;
		*) # task selection
			[ "$_task_exec" = "ALL" ] && _task_exec=()
			_task_exec+=("$(_ush_upper "$1")")
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
_ush_task() {
	local task="$1"; shift
	[ -n "$task" ] || _die "argument missing"

	# repeat task?
	local repeat=false

	# selective tasks
	if [ "$_task_exec" != "ALL" ]; then
		_in "$(_ush_upper "$task")" "${_task_exec[@]}" || return 1
	fi

	# list mode
	if $_task_opt_list; then
		local status="$(_ush_task-status "$task")"
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
		_ush_is-task "$task" DONE NEVER && return 1
	fi

	# parse args
	local context valid
	while [ $# -gt 0 ]; do
		valid=true

		case "$1" in
		-*) # non-contextual args
			context=""
			case "$1" in
			-r|--repeat)
				repeat=true ;;
			-d|--depend)
				context=DEPS ;;
			*) valid=false
			esac
			;;
		*) # contextual args
			case "$context" in
			DEPS) # check dependencies
				_ush_is-task "$1" DONE || return 1 ;;
			*) valid=false
			esac
		esac

		$valid || _die "invalid argument '$1'"
		shift
	done

	if _ush_is-task "$task" REPEAT; then
		repeat=true
	elif $_task_opt_prompt; then # prompt mode
		local answer
		while true; do
			echo "Run task:$task ?"
			read -n 1 -p "[ (R)un / (A)lways / (S)kip / (N)ever / (D)one already ] " answer; echo
			case "$answer" in
			[Rr]) echo "> Run";          break ;;
			[Aa]) echo "> Always";       repeat=true; break ;;
			[Ss]) echo "> Skip";         return 1 ;;
			[Nn]) echo "> Never";        _ush_set-task "$task" NEVER; return 1 ;;
			[Dd]) echo "> Done already"; _ush_set-task "$task" DONE;  return 1 ;;
			esac
		done
	fi

	_task_current="$task"
	_task_repeat=$repeat

	echo
	echo "TASK: $task ..."
}

# Sets the current task status to DONE
_ush_ksat() {
	[ -n "$_task_current" ] || _die "no active task"
	local status=DONE; $_task_repeat && status=REPEAT
	_ush_save-var "$_task_current" "$status" "$_task_save_to" || _die "failed to write: $_task_save_to"
	echo "TASK: $_task_current > $status"
	_task_current=""
	_task_repeat=false
}

_ush_fail() {
	echo "TASK: $_task_current > ERROR!"
	[ -z "$*" ] || echo " > $*"
	_ush_save-var "$_task_current" FAILED "$_task_save_to"
	exit 1
}

# Returns task status
_ush_task-status() {
	_ush_load-var "$1" "$_task_save_to"
}

# Checks task status
_ush_is-task() {
	local status="$(_ush_task-status "$1")"; shift
	_in "$status" "$@"
}

# Sets task status
_ush_set-task() {
	local task="$1"
	local status="$2"
	_ush_save-var "$task" "$status" "$_task_save_to" || _die "failed to write: $_task_save_to"
}

_ush_reset-task() {
	_ush_set-task "$1" RESET
}

_ush_reset-tasks() {
	echo "" > "$_task_save_to"
}
