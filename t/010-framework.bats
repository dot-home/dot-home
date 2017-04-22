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

# Because we're nervous types, we check that we've actually set up
# properly to use the correct versions of Bash etc. as per the
# presence/absence of the `-3` option on `Test`.

@test "expected BASH_VERSINFO" {
    assert_equal "$EXPECTED_BASH_VERSINFO" "$BASH_VERSINFO"
}

@test "BSD sed" {
    [ "$BASH_VERSINFO" -eq 4 ] && return
    run sed --version
    assert_failure
    assert_output --partial 'invalid option'
}

@test trim_spec {
    run trim_spec < <(echo '     ')
    assert_output ''

    run trim_spec <<.
        # Comments with leading space get removed
        # ↓ Empty lines get removed

        Some#content  # Comments (with leading space) can follow content
.
    assert_output 'Some#content'
}
