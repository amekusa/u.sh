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

##
# Initialize the task system
_ush_task-system() {
	while [ $# -gt 0 ]; do
		case "$1" in
		-s|--save-to)
			_task_save_to="$2"; shift
			[ -f "$_task_save_to" ] || touch "$_task_save_to" || _die "failed to create: $_task_save_to"
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
		-r|--reset)
			_ush_reset-tasks
			;;
		-*)
			echo "invalid argument '$1'"
			;;
		*) # task selection
			[ "$_task_exec" = "ALL" ] && _task_exec=()
			_task_exec+=("$(_ush_upper "$1")")
		esac
		shift
	done

	# hook
	trap _ush_task-system-on-int  INT
	trap _ush_task-system-on-exit EXIT
}

##
# Action on interruption
_ush_task-system-on-int() {
	[ -z "$_task_current" ] || _ush_fail "interrupted"
	exit 1
}

##
# Action on exit
_ush_task-system-on-exit() {
	local code="$?"
	if [ -z "$_task_current" ]; then
		if [ "$code" -eq 0 ]
			then _ush_done
			else _ush_fail
		fi
	fi
	exit "$code"
}

##
# Use this function to define a task
#
# Usage:
#   if _ush_task TASK_NAME; then
#     # do stuff
#   fi
#
# Another usage:
#   TASK_NAME() {
#     _ush_task
#     # do stuff
#   }
#
_ush_task() {
	# task name
	local task

	# parse args
	local context=ROOT
	local valid=true
	local repeat=false
	while [ $# -gt 0 ]; do
		case "$context" in
		DEPS) # check dependencies
			_ush_is-task "$1" DONE || return 1
			;;
		ROOT)
			case "$1" in
			-d|--depend)
				context=DEPS
				;;
			-r|--repeat)
				repeat=true
				;;
			*)
				if [ -z "$task" ]
					then task="$1"
					else valid=false
				fi
			esac
		esac
		$valid || _die "invalid argument '$1'"
		shift
	done

	# task name = function name
	if [ -z "$task" ]; then
		[ ${#FUNCNAME[@]} -lt 3 ] || _die "task name is missing"
		task="${FUNCNAME[$(( ${#FUNCNAME[@]} - 2 ))]}"
	fi

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

	# finish the previous task
	[ -z "$_task_current" ] || _ush_done

	# check task status
	if ! $_task_opt_force; then
		_ush_is-task "$task" DONE NEVER && return 1
	fi

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

##
# Sets the current task status to DONE
_ush_done() {
	[ -n "$_task_current" ] || _die "no active task"
	local status=DONE; $_task_repeat && status=REPEAT
	_ush_save-var "$_task_current" "$status" "$_task_save_to" || _die "failed to write: $_task_save_to"
	echo "TASK: $_task_current > $status"
	_task_current=""
	_task_repeat=false
}

##
# Sets the current task status to FAILED
_ush_fail() {
	echo "TASK: $_task_current > ERROR!"
	[ -z "$*" ] || echo " > $*"
	_ush_save-var "$_task_current" FAILED "$_task_save_to"
	exit 1
}

##
# Returns task status
_ush_task-status() {
	_ush_load-var "$1" "$_task_save_to"
}

##
# Checks task status
_ush_is-task() {
	local status="$(_ush_task-status "$1")"; shift
	_in "$status" "$@"
}

##
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

