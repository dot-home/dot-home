load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

mkdir_base() {
    local dir="$BATS_TEST_DIRNAME/../$1"
    mkdir -p "$dir"
    (cd "$dir" && pwd -P)
}

setup_home() {
    test_home="$(mkdir_base .build/test/home)"
    rm -rf "$test_home"; cp -r "$BATS_TEST_DIRNAME/mock-home" "$test_home"
}

@test "symlinker" {
    setup_home
    HOME="$test_home" run "$BATS_TEST_DIRNAME/../bin/dot-home-setup"
    (cd $test_home && find . \
               -type l  -exec bash -c 'echo -n {} "-> "; readlink {}' \; \
            -o -type d  -true  \
            -o          -print \
        | sed -e 's,^\./,,' | sort >../home.list)
    assert_output ''
    diff -u $BATS_TEST_DIRNAME/100-symlinker.expected $test_home/../home.list
}
