#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "string_utils.h"

int contains_substring(const char *haystack, const char *needle) {
    if (*needle == '\0') return 1; // An empty substring is technically "found"
    for (int i = 0; haystack[i] != '\0'; i++) {
        int j = 0;
        // If first characters match, check the rest of the substring
        while (haystack[i + j] == needle[j] && needle[j] != '\0') {
            j++;
        }
        // If we reached the end of the needle, we found a match
        if (needle[j] == '\0') {
            return 1;
        }
    }
    return 0;
}
char* get_until_delim(char* src, char* delim) {
    // 1. Find the index of the first occurrence of any character in delim
    size_t length = strcspn(src, delim);
    // 2. Allocate memory (length + 1 for the null terminator)
    char* result = (char*)malloc(length + 1);
    if (result != NULL) {
        // 3. Copy only the part we want
        strncpy(result, src, length);
        // 4. Null-terminate the new string
        result[length] = '\0';
    }
    return result;
}
char* get_after_delim(char* src, char delim) {
    // 1. Find the first occurrence of the delimiter
    char* pos = strchr(src, delim);
    // 2. If delimiter isn't found, or it's the very last character
    if (pos == NULL || *(pos + 1) == '\0') {
        return NULL; 
    }
    // 3. Move pointer to the character immediately following the delimiter
    char* start_ptr = pos + 1;
    // 4. Duplicate the remaining string
    // strdup handles malloc and strcpy in one go
    char* result = strdup(start_ptr);
    return result;
}
char* concat(const char *s1, const char *s2)
{
    char *result = (char*)malloc(strlen(s1) + strlen(s2) + 1); // +1 for the null-terminator
    // in real code you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

