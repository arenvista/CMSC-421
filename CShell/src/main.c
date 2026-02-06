#include "handles.h" 
#include "string_utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char* getCommand();

enum command {
    EXEC,   // [x] 
    ECHO,   // [x]
    TYPE,   // [x]
    EXIT,   // [x] Bonus Commands 
    PWD,    // [ ] Bonus Commands 
};

enum command resolveCommand(char* cmd_str) {
    if (cmd_str == NULL) return EXEC;
    // strcmp returns 0 if strings match
    if (strcmp(cmd_str, "exit") == 0) return EXIT;
    if (strcmp(cmd_str, "echo") == 0) return ECHO;
    if (strcmp(cmd_str, "pwd")  == 0) return PWD;
    if (strcmp(cmd_str, "type")  == 0) return TYPE;
    return EXEC;
}
int main(int argc, char *argv[]) {
    setbuf(stdout, NULL);
    char prompt[3] = "$ ";
    while (1) {
        printf("%s", prompt);
        char* usr_input = getCommand();
        if (usr_input == NULL) break; // Handle EOF/Error
        char* command_str = get_until_delim(usr_input, " ");
        
        // If the line has no spaces, the whole line is the command
        if (command_str == NULL || strlen(command_str) == 0) {
             command_str = strdup(usr_input); 
        }
        // Resolve the string to the Enum
        enum command cmd_id = resolveCommand(command_str);
        // Control flow using the Enum
        switch (cmd_id) {
            case EXIT:
                free(usr_input);
                if (command_str) free(command_str);
                exit(0); 
                break;

            case ECHO: {
                handle_echo(usr_input);
                break;
            }
            case PWD:
                handle_pwd(usr_input);
                break;

            case TYPE:
                handle_type(usr_input);
                break;

            case EXEC:
            default:
                execute_external(usr_input);
                break;
        }

        // Cleanup
        if (command_str != usr_input) free(command_str); // Only free if allocated separately
        free(usr_input);
    }
    return 0;
}

char* getCommand() {
    char* command = malloc(1024);
    if (command == NULL) return NULL;

    if (fgets(command, 1024, stdin)) {
        command[strcspn(command, "\n")] = 0;
        return command;
    }
    free(command);
    return NULL;
}
