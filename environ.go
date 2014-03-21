/**
 * Environment
 * http://cixtor.com/
 * https://github.com/cixtor/mamutools
 * http://en.wikipedia.org/wiki/Environment_variable
 *
 * Environment variables are a set of dynamic named values that can affect the
 * way running processes will behave on a computer. They are part of the
 * operating environment in which a process runs.
 *
 * In all Unix and Unix-like systems, each process has its own separate set of
 * environment variables. By default, when a process is created, it inherits a
 * duplicate environment of its parent process, except for explicit changes made
 * by the parent when it creates the child. At the API level, these changes must
 * be done between running fork and exec. Alternatively, from command shells
 * such as bash, a user can change environment variables for a particular
 * command invocation by indirectly invoking it via env or using the
 * ENVIRONMENT_VARIABLE=VALUE <command> notation.
 *
 * Examples of environment variables include:
 * - PATH - a list of directory paths. When the user types a command without
 *   providing the full path, this list is checked to see whether it contains
 *   a path that leads to the command.
 * - HOME - indicate where a user's home directory is located in the file system.
 * - HOME/{.AppName} - for storing application settings.
 * - TERM - specifies the type of terminal emulator being used (e.g., vt100 or dumb).
 * - PS1 - specifies how the prompt is displayed in the Bourne shell and variants.
 * - MAIL - used to indicate where a user's mail is to be found.
 * - TEMP - location where processes can store temporary files
 */
