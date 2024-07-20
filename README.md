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

# Supported variable interpolation types
|Expression|Description|
|-|-|
|`${Parameter}`|The value, if any, of the specified *Parameter* parameter is substituted|
|`${Parameter:-Word}`|If the *Parameter* parameter is set and is not null, then its value is substituted; otherwise, the value of the *Word* parameter is substituted.|
|`${Parameter:=Word}`|If the *Parameter* parameter is not set or is null, then it is set and its value is substituted to the value of the *Word* parameter.|

# Requirements
This shell script is made to be as much modern POSIX-compliant as possible. This means that the code inside could look really clunky and hard to understand in some way or another. This shell script was designed in mind for BusyBox v1.36.1 `ash` shell and tested using Alpine Linux WSL instance. This was also briefly tested with `bash` using Ubuntu distribution.

In order for this shell script to work it requires these commands to be available in your environment:
- sed
- grep
- cut
- find
- mktemp