load 'test-lib'

@test "pass" {
    assert true
    refute false
}

test_run_function() { echo test_run_function; return 17; }

@test "run for functions" {
    run test_run_function
    assert_failure 17
    assert_output test_run_function
}

@test "framework variables" {
    run echo "$build_dir"
    assert_output --partial '/.build'
    assert_output --regexp  "^$build_dir"
    assert [ -d "$build_t_dir" ]
    assert_equal "$(ls -A $build_t_dir)" ''     # Assert empty dir
}
