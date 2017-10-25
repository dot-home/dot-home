load 'test-lib'

teardown() {
    assert_test_home
}

@test "Non-existent ~/.home" {
    create_test_home </dev/null
    run_setup_on_test_home -p symlink
    assert_failure
    diff_test_home_with <<.
        .
.
    assert_output -p '.home ERROR: Cannot change to'
}

@test "No modules in ~/.home" {
    create_test_home <<.
        .home/.ignored
        bin/whatever
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        .home/.ignored
        bin/whatever
.
    assert_output ''
}

@test "no pre-existing symlinks" {
    create_test_home <<.
        .home/AAA/bin/a file
        .home/BBB/bin/a dir/a file
        .home/AAA/dot/a file
        .home/BBB/dot/a dir/a file
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        .local/bin/a file -> ../../.home/AAA/bin/a file
        .local/bin/a dir/a file -> ../../../.home/BBB/bin/a dir/a file
        .a file -> .home/AAA/dot/a file
        .a dir/a file -> ../.home/BBB/dot/a dir/a file
.
    assert_output ''
}

@test "pre-existing correct symlink untouched" {
    create_test_home <<.
        .home/AAA/dot/config
        .config -> .home/AAA/dot/config
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        .config -> .home/AAA/dot/config
.
    assert_output ''
}

@test "pre-existing incorrect symlink into .home just alerts" {
    create_test_home <<.
        .home/FIRST/dot/config
        .home/SECOND/dot/config
        .config -> .home/SECOND/dot/config
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        # Would be linked to FIRST if link didn't already exist
        .config -> .home/SECOND/dot/config
.
    assert_output '.home WARNING: Conflict: .home/FIRST/dot/config'
}

@test "untriggered pre-existing symlink into .home" {
    create_test_home <<.
        .home/AAA/just so .home exists  # because non-existent .home test above
        .config -> .home/gone/dot/config
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        #  This is not removed because, though it points inside ~/.home/,
        #  there is no .home/*/bin/dangling inside that would trigger
        #  us to look at it.
        .config -> .home/gone/dot/config
.
    assert_output ''
}

@test "conflicts with files in .home" {
    create_test_home <<.
        .home/AAA/dot/config
        .home/BBB/dot/config
        .home/CCC/dot/config/ha ha it's a dir!
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
       .config -> .home/AAA/dot/config
.
    assert_output <<.
.home WARNING: Conflict: .home/BBB/dot/config
.home WARNING: Conflict: .home/CCC/dot/config/
.home WARNING: Conflict: .home/CCC/dot/config/ha ha it's a dir!
.
}

@test "conflicts in aliased directories in a .home module" {
    create_test_home <<.
        .home/AAA/bin/b
        .home/AAA/dot/local/bin/b
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
       .local/bin/b -> ../../.home/AAA/bin/b
.
    assert_output <<.
.home WARNING: Conflict: .home/AAA/dot/local/bin/b
.
}

# Existing files never get overwritten.
@test "conflicts with files and symlinks outside of .home" {
    create_test_home <<.
        .home/AAA/dot/config
        .config
        .home/AAA/dot/linked
        .linked -> .other-file
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        .config
        .linked -> .other-file
.
    assert_output <<.
.home WARNING: Conflict: .home/AAA/dot/config
.home WARNING: Conflict: .home/AAA/dot/linked
.
}

@test "pre-existing dangling symlink into .home" {
    create_test_home <<.
        .home/AAA/bin/a file
        .home/AAA/dot/a file
        .home/AAA/dot/an absolute link
        .home/AAA/dot/a dir/a file
        .local/bin/a file -> ../../.home/does not/exist at/all
        .a file -> .home/does not/exist at/all
        .a dir/a file -> ../.home/does not/exist at/all
        .an absolute link -> $test_home/.home/does not/exist at/all
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        .local/bin/a file -> ../../.home/AAA/bin/a file
        .a file -> .home/AAA/dot/a file
        .an absolute link -> .home/AAA/dot/an absolute link
        .a dir/a file -> ../.home/AAA/dot/a dir/a file
.
    assert_output ''
}

@test "inb4 files are ignored" {
    create_test_home <<.
        .home/AAA/dot/dir/config1
        .home/AAA/dot/dir/config2.inb4
        .home/BBB/dot/dir/config2.inb0
        .home/CCC/dot/dir/config2.inb9
.
    run_setup_on_test_home -p symlink
    assert_success_and_diff_test_home_with <<.
        .dir/config1 -> ../.home/AAA/dot/dir/config1
.
    assert_output ''
}
