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
    assert_output --regexp '(invalid|illegal) option --'
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

@test assert_function {
    f() { echo "1<$1> 2<$2> 3<$3> 4<$4>"; }
    run assert_function  f  <<.
        # Arguments are separated by Unicode bullet operator (U+2219).
        # In vim, insert this with digraph <Ctrl-K S b>.
                                    ⇒ 1<> 2<> 3<> 4<>           # no args
        o n e                       ⇒ 1<o n e> 2<> 3<> 4<>
        o n e ∙ t w o               ⇒ 1<o n e> 2<t w o> 3<> 4<>
        o n e ∙ t w o ∙             ⇒ 1<o n e> 2<t w o> 3<> 4<>
        o n e ∙ t w o ∙   ∙ 4       ⇒ 1<o n e> 2<t w o> 3<> 4<4>
        o n e ∙ t w o ∙   ∙ 4 ∙ 5   ⇒ 1<o n e> 2<t w o> 3<> 4<4>
.
    assert_output ''
    assert_success
}

@test "assert_function fails when command does not exist" {
    run assert_function 2>&1 does_not_exist  <<.
        ⇒ 1<> 2<> 3<> 4<>
.
    assert_failure
    assert_output --partial 'does_not_exist: command not found'
}

@test "assert_function fails when does not match spec" {
    f() { echo "1<$1> 2<$2> 3<$3> 4<$4>"; }
    run assert_function 2>&1 f  <<.
    ⇒ 1<> 2<> 3<> 4<>
    ⇒ 1<x> 2<x> 3<x> 4<x>
.
    assert_failure
    assert_output <<.
-- assert_function 'f' failure(s) --
spec   : ⇒ 1<x> 2<x> 3<x> 4<x>
actual : 1<> 2<> 3<> 4<>
--
1 specifications failed
.
}
