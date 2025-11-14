load 'test-lib'

setup() {
    test_lib_setup
    export HOME=/dev/null
    source "$BATS_TEST_DIRNAME/../bin/dot-home-setup" --define-functions-only
}

@test for_each_module {
    say() { echo "        $1 $2$4$3"; }
    run for_each_module \
        ",inb4 ,local.git -x _inb4 00-fred Fred local mycompany.com public" \
        say 'module :' '<' '>'          # Test arg with a space
    assert_success
    assert_output <<.
        module : <_inb4>
        module : <00-fred>
        module : <Fred>
        module : <local>
        module : <mycompany.com>
        module : <public>
.
}

@test for_each_module_failure {
    f() {
        case "$1" in
            ok) echo -n 'good '; return 0;;
            *)  echo -n 'an error!'; return 1;;
        esac
    }
    run for_each_module 'ok ok err ok' f    # Test no extra args to `f`
    assert_failure
    assert_output 'good good an error!'
}

