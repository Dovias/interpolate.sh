# interpolate.sh
Shell script for Unix-like systems which interpolates shell and environment variables within the files.
```
Usage: interpolate.sh [options] [operands] input_path output_path [variable_name[=data]...]
Options:
        -f, --force-override-output             Forcefully overrides any files that are in output_path
        -h, --help                              Displays this usage message
        -o, --output-interpolated-only          Outputs only interpolated files to output_path
        -v, --verbose-logging                   Enables verbose logging
Operand options:
        -d, --traverse-depth[=]depth            Specifies depth, which input_path directory would be traversed for interpolation recursively
        -e, --environment-variable[=]regex      Enables interpolation of filtered environment variables in input_path by given regular expression
        -i, --input-path[=]regex                Filters input_path directory by given regular expression
```

# Requirements
This shell script is made to be as much POSIX-compliant as possible. This means that the code inside could look really clunky and hard to understand in some way or another. This shell script was designed in mind with busybox's `ash` shell and tested using Alpine Linux WSL instance. Also briefly tested with `bash` using Ubuntu distribution.

In order for this shell script to work it requires these commands to be available in your environment:
- sed
- grep
- cut
- find
- mktemp

## What is the point of this?
This shell script allows you to create template-like folder structures with placeholders which you can populate with proper values that are provided via the shell. That means you can preprocess files for deployment of your application.
