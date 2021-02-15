# bash args
An argument parsing library for bash scripts

Usage:

Source the library, then define keyword and required arguments and call the `parse_args` function.

```bash
# Define a description which will be used in the --help message
DESCRIPTION="A dummy function to showcase the bash-args library"
# Define a usage message which will be used in the --help message and during argument parsing errors
USAGE="my_example_func [OPTIONS] username

  username
    Your username
  
  Options
    --config file        Read configuration from a file
    -i, --interactive    Ask before doing anything dangerous
    -s, --sleep duration Sleep <duration> seconds before doing anything"

# Define the keywords to use for (optional keyword arguments
KEYWORDS=("--config" "--interactive;bool" "-i;bool" "--sleep;int" "-s;int")
# Define required positional arguments
REQUIRED=("username")
# Source the library
. ./parse_args.sh
# Parse all arguments in "$@"
parse_args __USAGE "$USAGE" __DESCRIPTION "$DESCRIPTION" "$@"

# Show the usage message on specific exit codes
set_trap 1 2

# Retrieve the arguments

echo "Your arguments:"
echo "username: ${NAMED_ARGS['username']}"
echo "config: ${KW_ARGS['--config']}"
echo "interactive: ${KW_ARGS['--interactive']-${KW_ARGS['-i']}"

# Set a default value for the sleep argument
sleep="${KW_ARGS['--sleep']-${KW_ARGS['-s']}}"
sleep="${sleep-0}"
echo "sleep: $sleep"
echo "any other args you provided: ${ARGS[@]}"
```
