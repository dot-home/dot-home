load 'test-lib'

setup() {
    test_lib_setup
    export HOME=/dev/null
    source "$BATS_TEST_DIRNAME/../bin/dh" --define-functions-only
}

@test "deps: deps_remove_existing" {
    run deps_remove_existing "$base_dir" <<.
        bin    _ _
        bin    _ _2
        nope   _ _
.
    assert_success
    assert_output 'nope _ _'
}

@test "deps: deps_conflict_check" {
    run deps_conflict_check <<.
        BBB _ somearg
        BBB _ some-other-arg
        CCC _ _
.
    assert_success
    assert_output <<.
BBB _ somearg
.home WARNING: Duplicate module dependency: BBB
CCC _ _
.
}

@test "deps: deps_command_generator" {
    local retval=0
    deps_command_generator <<.
        oops borken https://aaa
        AAA  git    https://aaa
        BBB  git    https://bbb
.
    [[ ${deps_commands[0]} =~ 'Unknown dependency type: borken' ]]
    [[ ${deps_commands[1]} =~ "git clone 'https://aaa' 'AAA'" ]]
    [[ ${deps_commands[2]} =~ "git clone 'https://bbb' 'BBB'" ]]
    [[ ${#deps_commands[@]} =  3 ]]
}
