load 'test-lib'

@test "test test_home" {
    create_test_home <<_
        # Blank lines and comment-only lines are ignored

        .home/AAA/a file                # automatically added to expected
        .home/,build                    # not automatically added
        .homey                          # not in .home
        another file
        a symlink -> nothing at all     # test this comment :-)
_
    run true    # In real tests this is run_dh_on_test_home
    assert_success_and_diff_test_home_with <<_
        # Order does not matter here
        another file
        a symlink -> nothing at all
        .homey
        .home/,build
_
    assert_output ''
    assert_test_home
}
