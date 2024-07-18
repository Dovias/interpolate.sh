#!/bin/sh

for cmd in sed grep cut find mktemp; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "This script requires command '$cmd' to function properly" >&2
        exit 1
    fi
done

is_number () {
	case "$1" in
		''|*[!0-9]*) return 1;;
		*) return 0;;
	esac
}

escape_forward_slash () {
	echo "$1" | sed 's/\//\\\//g'
}

display_usage () {
	if [ -n "$1" ]; then
		echo "Error: $1"
	fi

	cat << EOL
$0: interpolates variables for input_path and outputs them into output_path
Usage: $0 [options] [operands] input_path output_path [variable_name[=data]...]
Options:
	-f, --force-override-output		Forcefully overrides any files that are in output_path
	-h, --help				Displays this usage message
	-o, --output-interpolated-only		Outputs only interpolated files to output_path
	-v, --verbose-logging			Enables verbose logging
Operand options:
	-d, --traverse-depth[=]depth		Specifies depth, which input_path directory would be traversed for interpolation recursively
	-e, --environment-variable[=]regex	Enables interpolation of filtered environment variables in input_path by given regular expression
	-i, --input-path[=]regex		Filters input_path directory by given regular expression
EOL

	exit 1
}

force_override_output=false
output_interpolated_only=false
verbose_logging=false
while true; do
	case "$1" in
	'-d'|'--traverse-depth')
		traverse_depth="$2"
		if [ -z "$traverse_depth" ] || ! is_number "$traverse_depth"; then display_usage "$1 operand should be specified as a natural number"; fi
		if [ $traverse_depth -lt 1 ]; then display_usage "$1 operand cannot be less than 1"; fi

		shift
		;;
	'--traverse-depth='*)
		option=$(echo "$1" | cut -d= -f1)
		traverse_depth="$(echo "$1" | cut -d= -f2)"
		if ! is_number "$traverse_depth"; then display_usage "$option operand should be specified as a natural number"; fi
		if [ $traverse_depth -lt 1 ]; then display_usage "$option operand cannot be less than 1"; fi

		;;
	'-e'|'--environment-variable')
		environment_variable_regex="$2"
		if [ -z "$environment_variable_regex" ]; then display_usage "Missing $1 option regular expression operand"; fi

		shift
		;;
	'--environment-variable='*)
		environment_variable_regex="$(echo "$1" | cut -d= -f2)"
		;;
	'-f'|'--force-override-output')
		force_override_output=true
		;;
	'-h'|'--help') display_usage;;
	'-i'|'--input-path')
		file_path_regex="$2"
		if [ -z "$file_path_regex" ]; then display_usage "Missing $1 option regular expression operand"; fi

		shift
		;;
	'--input-path='*)
		file_path_regex="$(echo "$1" | cut -d= -f2)"
		;;
	'-o'|'--output-interpolated-only')
		output_interpolated_only=true
		;;
	'-v'|'--verbose-logging')
		verbose_logging=true
		;;
	*) break;	
	esac

	shift
done

if [ $#  -eq 0 ]; then display_usage; fi
if [ $#  -eq 1 ]; then display_usage "Missing output_path argument"; fi


input_path=$1
if ! [ -d "$input_path" ]; then display_usage "Provided input_path argument '$input_path' is not a directory"; fi

output_path=$2
if [ -d "$output_path" ] && [ ! -r "$output_path" ]; then display_usage "Provided output argument '$output_path' directory cannot be written"; fi

shift 2

verbose_execute () {
	if $verbose_logging; then "$@"; fi
}

temp_file_path="$(mktemp)"
verbose_execute echo "Created temporary file in file path: $temp_file_path"


if [ -n "$environment_variable_regex" ]; then
	interpolation_variables="$(printenv | cut -d= -f1 | grep -E "$environment_variable_regex" | while read variable; do
		echo "$variable=$(printenv "$variable")";
	done) $@"
else
	interpolation_variables=$@
fi

input_file_paths="$(
	if [ -n "$traverse_depth" ]; then
		find -L "$input_path" -maxdepth "$traverse_depth" -type f
	else
		find -L "$input_path" -type f
	fi
)"

if [ -n "$file_path_regex" ]; then
	input_file_paths="$(echo "$input_file_paths" | grep -E "$file_path_regex")"
fi

for input_file_path in $input_file_paths; do
	output_file_path="$(echo "$input_file_path" | sed "s/$(escape_forward_slash $input_path)/$(escape_forward_slash $output_path)/")"
	verbose_execute echo "Attempting to interpolate given variables in input file path: $input_file_path"

	verbose_execute echo "Copying input file path ($input_file_path) contents into temporary file path: $temp_file_path"
	cp "$input_file_path" "$temp_file_path"

	input_file_interpolated=false
	for interpolation_variable in $interpolation_variables; do
		key=$(escape_forward_slash "${interpolation_variable%%=*}")
		value=$(escape_forward_slash "$(echo "$interpolation_variable" | cut -sd= -f2)")
		sed -n "" "$temp_file_path"
		latter_interpolation="$(verbose_execute sed -n "s/.*\(\${$key\(:=.\+\)\?}\).*/\1/p" "$temp_file_path")"
		if [ -n "$latter_interpolation" ]; then
			echo "Interpolating $latter_interpolation variable in input file path: $input_file_path"
			input_file_interpolated=true
		fi
		
		sed -i "s/\${$key\(:=.\+\)\?}/$value/g" "$temp_file_path"
	done

	if $output_interpolated_only && ! $input_file_interpolated; then continue; fi

	verbose_execute echo "Copying processed input file contents into output file path: $output_file_path"
	mkdir -p "$(dirname "$output_file_path")"
	if $force_override_output; then
		cp "$temp_file_path" "$output_file_path"
	else
		cp -i "$temp_file_path" "$output_file_path" < /dev/tty
	fi
done

cleanup () {
	verbose_execute echo "Removing temporary file in file path: $temp_file_path"
	rm -rf "$temp_file_path"
}

trap cleanup EXIT