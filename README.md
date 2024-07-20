# interpolate.sh
Shell script for Unix-like systems which interpolates shell and environment variables within the files.
```
Usage: interpolate.sh [options] [operands] input_path output_path [variable_name[=data]...]
Options:
        -f, --forced-output                     Forcefully overrides any files that are in output_path
        -h, --help                              Outputs this usage message
        -o, --interpolated-output-only          Outputs only interpolated files to output_path
        -v, --verbose-logging                   Enables verbose logging
Operand options:
        -e, --environment-variable[=]regex      Enables interpolation of filtered environment variables in input_path by given regular expression
        -i, --input-path[=]regex                Filters input_path directory by given regular expression
        -p, --pass-amount[=]number              Specifies amount of how many attempts will be tried to interpolate the variables sequentially
        -t, --traverse-depth[=]number           Specifies depth of how deep input_path directory would be traversed recursively
```

## What is the point of this?
This shell script allows you to create template-like folder structures with placeholders which you can populate with proper values that are provided via the shell. That means you can preprocess files for deployment of your application.

# Requirements
This shell script is made to be as much POSIX-compliant as possible. This means that the code inside could look really clunky and hard to understand in some way or another. This shell script was designed in mind with busybox's `ash` shell and tested using Alpine Linux WSL instance. Also briefly tested with `bash` using Ubuntu distribution.

In order for this shell script to work it requires these commands to be available in your environment:
- sed
- grep
- cut
- find
- mktemp

# Variable interpolation examples
|Expression|Command|Result|
|-|-|-|
|${VARIABLE_NAME}|`interpolate.sh input_path output_path`|**${VARIABLE_NAME}**|
|${VARIABLE_NAME}|`interpolate.sh input_path output_path VARIABLE_NAME`||
|${VARIABLE_NAME}|`interpolate.sh input_path output_path VARIABLE_NAME=`||
|${VARIABLE_NAME}|`interpolate.sh input_path output_path VARIABLE_NAME=VARIABLE_DATA`|**VARIABLE_DATA**|
|${VARIABLE_NAME}|`interpolate.sh -e VARIABLE_NAME input_path output_path`||
|${VARIABLE_NAME}|`VARIABLE_NAME=VARIABLE_DATA interpolate.sh -e VARIABLE_NAME input_path output_path`|**VARIABLE_DATA**|
|${VARIABLE_NAME:=VARIABLE_DEFAULT_DATA}|`interpolate.sh input_path output_path`|**VARIABLE_DEFAULT_DATA**|
|${VARIABLE_NAME:=VARIABLE_DEFAULT_DATA}|`interpolate.sh input_path output_path VARIABLE_NAME`||
|${VARIABLE_NAME:=VARIABLE_DEFAULT_DATA}|`interpolate.sh input_path output_path VARIABLE_NAME=`||
|${VARIABLE_NAME:=VARIABLE_DEFAULT_DATA}|`interpolate.sh input_path output_path VARIABLE_NAME=VARIABLE_DATA`|**VARIABLE_DATA**|
|${VARIABLE_NAME:=VARIABLE_DEFAULT_DATA}|`interpolate.sh -e VARIABLE_NAME input_path output_path`|**VARIABLE_DEFAULT_DATA**|
|${VARIABLE_NAME:=VARIABLE_DEFAULT_DATA}|`VARIABLE_NAME=VARIABLE_DATA interpolate.sh -e VARIABLE_NAME input_path output_path`|**VARIABLE_DATA**|
