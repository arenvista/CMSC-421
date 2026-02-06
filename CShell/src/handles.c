#include "handles.h"
#include "string_utils.h" 
#include <sys/wait.h> // Required for waitpid
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h> // Required for access() and X_OK
#include "handles.h"
#include "string_utils.h" // Required for get_after_delim

void handle_echo(char* usr_input){
    char* delim = " ";
    char* arg = get_after_delim(usr_input, *delim); 
    if (arg) {
        char* output = concat(arg, "\n");
        printf("%s", output);
        free(output);
    } else {
        printf("\n");
    }
    free(arg);
}

void handle_type(char* usr_input){
    // 1. Get the command name argument (strip "type " from "type <cmd>")
    char* command = get_after_delim(usr_input, ' ');
    
    // Safety check if user just typed "type" without arguments
    if (command == NULL) {
        return;
    }

    // 2. Check for Shell Builtins
    // Note: Based on your test requirements, 'ls' is treated as external here.
    if (strcmp(command, "echo") == 0 ||
        strcmp(command, "exit") == 0 || 
        strcmp(command, "type") == 0) {
        printf("%s is a shell builtin\n", command);
        free(command);
        return;
    }

    // 3. Search PATH environment variable
    char* path_env = getenv("PATH");
    if (path_env != NULL) {
        // strdup is vital because strtok modifies the string in place
        char* path_copy = strdup(path_env); 
        char* dir = strtok(path_copy, ":");

        while (dir != NULL) {
            // Calculate length: dir + "/" + command + null terminator
            size_t full_path_len = strlen(dir) + strlen(command) + 2;
            char* full_path = malloc(full_path_len);
            
            // Construct the path: /usr/bin/ls
            snprintf(full_path, full_path_len, "%s/%s", dir, command);

            // 4. Check if file exists and is executable
            if (access(full_path, X_OK) == 0) {
                printf("%s is %s\n", command, full_path);
                
                // Cleanup and return immediately on first match
                free(full_path);
                free(path_copy);
                free(command);
                return;
            }

            free(full_path);
            // Move to next directory in PATH
            dir = strtok(NULL, ":");
        }
        free(path_copy);
    }

    // 5. Not found
    printf("%s: not found\n", command);
    free(command);
}

void handle_ls(char* usr_input){
    printf("Listing directories... (Not implemented)\n");
}

void handle_pwd(char* usr_input){
    printf("Printing Working Dir... (Not implemented)\n");
}

void execute_external(char* usr_input) {
    // 1. Prepare arguments array (argv) for execvp
    // We assume a max of 100 arguments for simplicity
    char *args[100]; 
    int arg_count = 0;
    
    // Tokenize the input by spaces
    // Note: strtok modifies usr_input in place, which is safe here 
    // because usr_input is heap-allocated and freed later in main.
    char *token = strtok(usr_input, " ");
    while (token != NULL && arg_count < 99) {
        args[arg_count++] = token;
        token = strtok(NULL, " ");
    }
    args[arg_count] = NULL; // Array must be NULL-terminated

    if (arg_count == 0) return;

    // 2. Fork the process
    pid_t pid = fork();

    if (pid == 0) {
        // --- CHILD PROCESS ---
        // execvp searches the PATH for the command (args[0])
        // and passes the arguments array.
        execvp(args[0], args);
        
        // If execvp returns, it means execution failed (e.g. not found)
        printf("%s: command not found\n", args[0]);
        exit(1); // Exit child with error
    } else if (pid > 0) {
        // --- PARENT PROCESS ---
        // Wait for the child process to complete
        int status;
        waitpid(pid, &status, 0);
    } else {
        perror("fork failed");
    }
}
