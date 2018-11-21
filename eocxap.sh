#!/usr/bin/env bash
#
# This program allows the quick adding of hats to selected text
# Copyright (c) 2018 Zachary Matthews.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

set -euo pipefail

alt=false
h_system=false
inline=false
silent=false
stime=1
# Get default system languae as default locale setting
locale=$(locale | grep "LANG" | cut -d= -f2 | cut -d_ -f1)

print_usage() {
	echo "Usage: eocxap [OPTION]..."
	echo "Options(Agordoj):"
	echo "  -a, --alt             use alternate copy/paste(Ctrl/Shift+Insert)"
	echo "      --alia            uzu alia kopii/alglui metodo(Ctrl/Shift+Insert)"
	echo "      --en              display all messages in English"
	echo "                        prezenti ĉiujn mesaĝojn angle"
	echo "      --eo              display all messages in Esperanto"
	echo "                        prezenti ĉiujn mesaĝojn Esperante"
	echo "      --help            display this help message"
	echo "      --helpi           prezenti ĉi tiun mesaĝon de helpo"
	echo "  -h, --hsystem         use h-system for conversion"
	echo "      --hsistemo        uzi h-sistemo por konverti"
	echo "  -i, --inline          edit highlighted text in place"
	echo "      --enteksta        redakti markan tekston en sama loko"
	echo "      --silent          supress all messages"
	echo "      --silenta         kaŝi ĉiujn mesaĝojn"
	echo "  -s, --sleep=TIME      set the sleep timer when using inlne"
	echo "      --halteto=TIME    ŝanĝi la daŭro de halteto por enteksta reĝimo"
	echo "      --version         show the version information for eocxap"
	echo "      --versio          elmontri la versia informacio de eocxap"
	echo "  -w                    use w instead of ux when using the X-system"
	echo "                        uzi w anstataŭ ux kiam uzanta per X-sistemo"
	echo ""
	echo "Exit Status(Elira Kodo):"
	echo "  0  if OK"
	echo "  0  se bona"
	echo "  1  if general problem"
	echo "  1  se ĝenerala problemo"
	echo "  2  if serious problem"
	echo "  2  se serioza problemo"
	echo "  64 if programming issue"
	echo "  64 se problemo de programado"
	exit 0
}

print_version() {
	echo "eocxap, version 0.1"
	echo "Copyright (C) 2018 Zachary Matthews"
	echo "License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>"
	echo ""
	echo "This is free software; you are free to change and redistribute it."
	echo "There is NO WARRANTY, to the extent permitted by law."
	exit 0
}

print_err() {
	if (! $silent); then
		# If enough parameters and locale is eo, else use en
		if [ "$#" -gt "1" ] && [[ "$locale" == "eo" ]]; then
			echo "$2" 1>&2
		else
			echo "$1" 1>&2
		fi
	fi
}

check_depends() {
	# Check for xsel
	if ! type xsel >> /dev/null; then
		print_err "Xsel is not installed. Please install xsel." "Xsel ne estas instalita. Bonvolu instali xsel."
		exit 1
	fi
}

main() {
	check_depends

	# Getopt
	local short=ahis:w
	local long=alt,alia,en,eo,hsystem,hsistemo,inline,enteksta,silent,silenta,sleep:,halteto:,help,helpi,version,versio

	parsed=$(getopt --options $short --longoptions $long --name "$0" -- "$@")
	if [[ $? != 0 ]]; then
		# Getopt not getting arguments correctly
		exit 2
	fi

	eval set -- "$parsed"

	# Deal with command-line arguments
	while true; do
		case $1 in
			-a|--alt|--alia)
				alt=true
				;;
			--en)
				locale="en"
				;;
			--eo)
				locale="eo"
				;;
			--help|--helpi)
				print_usage
				;;
			-h|--hsystem|--hsistemo)
				h_system=true
				;;
			-i|--inline|--enteksta)
				if ! type xdotool >> /dev/null; then
					print_err "Xdotool is not installed. Please install xdotool to use $1." "Xdotool ne estas instalita. Bonvolu instali xdotool por uzi $1."
					exit 1
				fi
				inline=true
				;;
			--silent|--silenta)
				silent=true
				;;
			-s|--sleep|--halteto)
				stime="$2"
				# Check if stime is a number
				if [[ ! $stime =~ ^[0-9]+([.][0-9]+)?$ ]]; then
					print_err "$stime is not a number" "$stime ne estas numero"
					exit 1
				fi
				shift
				;;
			--version|--versio)
				print_version
				;;
			-w)
				sub_w=true
				;;
			--)
				shift
				break
				;;
			*)
				# Unknown option
				print_err "$1 argument not properly handled." "$1 argumento ne prave uzis."
				exit 64
				;;
		esac
		shift
	done

	if ! ($inline) && ($alt); then
		print_err "--alt needs --inline to function" "--alia devas --enteksta por funkcii"
	fi

	# If inline edit, copy text
	if ($inline); then
		old_clip=$(xsel -bo)
		# Sleep one second to allow for the release of any held keys
		sleep "$stime"
		if ! ($alt); then
			xdotool key --clearmodifiers Ctrl+C
		else
			xdotool key --clearmodifiers Ctrl+Insert
		fi
	fi

	# Get current selection from Ctrl+C clipboard
	clip=$(xsel -bo)

	if ! ($h_system); then
		if ($sub_w); then
			u_sub='s/w/\xc5\xad/g; s/W/\xc5\xac/g;'
		else
			u_sub=' s/u\(x\|X\)/\xc5\xad/g; s/U\(x\|X\)/\xc5\xac/g;'
		fi
		# Replace all matching characters(X-system)
		edit=$(sed -e "s/c\\(x\\|X\\)/\\xc4\\x89/g; s/g\\(x\\|X\\)/\\xc4\\x9d/g; s/j\\(x\\|X\\)/\\xc4\\xb5/g; s/h\\(x\\|X\\)/\\xc4\\xa5/g; s/s\\(x\\|X\\)/\\xc5\\x9d/g; s/H\\(x\\|X\\)/\\xc4\\xa4/g; s/C\\(x\\|X\\)/\\xc4\\x88/g; s/g\\(x\\|X\\)/\\xc4\\x9c/g; s/J\\(x\\|X\\)/\\xc4\\xb4/g; s/S\\(x\\|X\\)/\\xc5\\x9c/g; $u_sub" <<< "$clip")
	else
		# Replace all matching characters(H-system)
		edit=$(sed -e 's/c\(h\|H\)/\xc4\x89/g; s/g\(h\|H\)/\xc4\x9d/g; s/j\(h\|H\)/\xc4\xb5/g; s/h\(h\|H\)/\xc4\xa5/g; s/s\(h\|H\)/\xc5\x9d/g; s/H\(x\|H\)/\xc4\xa4/g; s/C\(h\|H\)/\xc4\x88/g; s/g\(h\|H\)/\xc4\x9c/g; s/J\(h\|H\)/\xc4\xb4/g; s/S\(h\|H\)/\xc5\x9c/g;' <<< "$clip")
	fi

	# Only change clipboard if edits were made
	if [ ! -z "$edit" ]; then
		xsel -bi <<< "$edit"
	fi

	# If inline paste text
	if ($inline); then
		if ! ($alt); then
			xdotool key --clearmodifiers Ctrl+V
		else
			xdotool key --clearmodifiers Shift+Insert
		fi
		xsel -bi <<< "$old_clip"
	fi
}

main "$@"
