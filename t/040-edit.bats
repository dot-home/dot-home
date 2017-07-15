load 'test-lib'

setup() {
    editor_func() { for arg in "$@"; do echo "$arg"; done; }
    export -f editor_func
    export EDITOR=editor_func
    test_lib_setup
}

@test "dh edit" {
    create_test_home <<.
        .home/AAA/dot/bar
        .home/AAA/dot/config file.inb4
        .home/BBB/dot/config file.inb1
        .home/CCC/dot/config file        # Conflicts, but we should still edit it
        .home/,inb4/dot/config file
        .home/CCC/dot/other config file  # Exact matches only
.
    run_dh_on_test_home edit 'config file' bar
    assert_output <<.
AAA/dot/config file.inb4
BBB/dot/config file.inb1
CCC/dot/config file
AAA/dot/bar
.
    assert_success
}

@test "dh edit: no matching files" {
    create_test_home <<.
        .home/CCC/dot/other config file
.
    run_dh_on_test_home edit 'config file'
    assert_output -p 'No matching files.'
    assert_failure
}
