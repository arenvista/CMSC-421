#include <check.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include "string_utils.h"
#include "handles.h"

// --- STDOUT CAPTURE SETUP ---
// We need to capture what printf writes to verify it.
int original_stdout_fd;
FILE *captured_stdout;

void setup_stdout_capture(void) {
    // Save original stdout so we can restore it later
    original_stdout_fd = dup(STDOUT_FILENO);
    
    // Redirect stdout to a temporary file
    captured_stdout = freopen("test_output.txt", "w+", stdout);
}

void teardown_stdout_capture(void) {
    // Flush anything pending
    fflush(stdout);
    
    // Restore original stdout
    dup2(original_stdout_fd, STDOUT_FILENO);
    close(original_stdout_fd);
    
    // If we want to clean up the temp file, we can, 
    // but leaving it can be useful for debugging failed tests.
}

// Helper to read the captured content back into a string
char* read_captured_output() {
    fseek(captured_stdout, 0, SEEK_SET); // Go to beginning of file
    
    // Allocate a buffer (assuming output isn't huge for these tests)
    char *buffer = calloc(1024, sizeof(char));
    fread(buffer, 1, 1023, captured_stdout);
    return buffer;
}

// --- TEST CASE: handle_echo ---
START_TEST(test_handle_echo_basic)
{
    // Scenario: User types "echo hello"
    char input[] = "echo hello"; 
    
    handle_echo(input);
    
    char *output = read_captured_output();
    ck_assert_str_eq(output, "hello\n");
    
    free(output);
}
END_TEST

START_TEST(test_handle_echo_empty)
{
    // Scenario: User types "echo" (no args)
    char input[] = "echo";
    
    handle_echo(input);
    
    char *output = read_captured_output();
    ck_assert_str_eq(output, "\n"); // Should just print a newline
    
    free(output);
}
END_TEST

// --- TEST CASE: handle_type ---
START_TEST(test_handle_type_builtin)
{
    // Scenario: User types "type exit"
    char input[] = "type exit";
    
    handle_type(input);
    
    char *output = read_captured_output();
    ck_assert_str_eq(output, "exit is a shell builtin\n");
    
    free(output);
}
END_TEST

START_TEST(test_handle_type_unknown)
{
    // Scenario: User types "type randomthing"
    char input[] = "type randomthing";
    
    handle_type(input);
    
    char *output = read_captured_output();
    ck_assert_str_eq(output, "randomthing: not found\n");
    
    free(output);
}
END_TEST

// --- PREVIOUS STRING UTILS TESTS (Kept for completeness) ---
START_TEST(test_get_after_delim_valid)
{
    char *result = get_after_delim("echo hello", ' ');
    ck_assert_str_eq(result, "hello");
    free(result);
}
END_TEST

// --- SUITE SETUP ---
Suite *shell_suite(void)
{
    Suite *s;
    TCase *tc_handles;
    TCase *tc_utils;

    s = suite_create("Shell Tests");

    // 1. Test Case for Handles (Needs Output Capture)
    tc_handles = tcase_create("Handles");
    // Add the setup/teardown functions that redirect stdout
    tcase_add_checked_fixture(tc_handles, setup_stdout_capture, teardown_stdout_capture);
    
    tcase_add_test(tc_handles, test_handle_echo_basic);
    tcase_add_test(tc_handles, test_handle_echo_empty);
    tcase_add_test(tc_handles, test_handle_type_builtin);
    tcase_add_test(tc_handles, test_handle_type_unknown);
    suite_add_tcase(s, tc_handles);

    // 2. Test Case for String Utils (Does NOT need Output Capture)
    tc_utils = tcase_create("Utils");
    tcase_add_test(tc_utils, test_get_after_delim_valid);
    suite_add_tcase(s, tc_utils);

    return s;
}

int main(void)
{
    int number_failed;
    Suite *s;
    SRunner *sr;

    s = shell_suite();
    sr = srunner_create(s);

    srunner_run_all(sr, CK_NORMAL);
    number_failed = srunner_ntests_failed(sr);
    srunner_free(sr);

    return (number_failed == 0) ? EXIT_SUCCESS : EXIT_FAILURE;
}
