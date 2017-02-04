load 'test-lib'

teardown() {
    assert_test_home
}

assert_output_file() {
    sed -e 's/^  *//' \
    | diff -u --label expected - --label ".home/$1" "$test_home/.home/$1"
}

@test "run inb4" {
    create_test_home <<.
        .home/A/dot/0 subdir/ignored

        .home/A/dot/2 subdir/config.inb4
        .home/B/dot/2 subdir/config.inb3
        .home/B/dot/2 subdir/config.inb5
        .home/C/dot/2 subdir/config.inb4

        .home/D/dot/other module ignored

        # Same name but different subdir
        .home/C/dot/3 subdir/config.inb4
.
    run_setup_on_test_home -p inb4
    diff_test_home_with <<.
        # _built_ files
        .home/,inb4/dot/2 subdir/config
        .home/,inb4/dot/3 subdir/config

        # _installed_ files
        #.home/_inb4/dot/2 subdir/config
        #.home/_inb4/dot/3 subdir/config
.
    assert_output ''

    assert_output_file ',inb4/dot/2 subdir/config' <<.
        Content of .home/B/dot/2 subdir/config.inb3
        Content of .home/A/dot/2 subdir/config.inb4
        Content of .home/C/dot/2 subdir/config.inb4
        Content of .home/B/dot/2 subdir/config.inb5
.

    assert_output_file ',inb4/dot/3 subdir/config' <<.
        Content of .home/C/dot/3 subdir/config.inb4
.
}
