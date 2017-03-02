load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup_test_dirs() {
    base_dir="$(cd $BATS_TEST_DIRNAME/.. && pwd -P)"
    build_dir="$base_dir/.build"
    test_dir="$build_dir/test"

    mkdir -p "$build_dir"
    rm -rf "$test_dir"; mkdir -p "$test_dir"
}

setup() { setup_test_dirs; }

setup_home() {
    test_home="$test_dir/home"
    rm -rf "$test_home"
    cp -r "$BATS_TEST_DIRNAME/mock-home" "$test_home"
}

@test "symlinker" {
    setup_home
    HOME="$test_home" run "$BATS_TEST_DIRNAME/../bin/dot-home-setup"

    local expected="$test_dir/home.expected"
    sed -e '/^#/d' "$BATS_TEST_DIRNAME/100-symlinker.expected" >"$expected"

    local actual="$test_dir/home.actual"
    (cd $test_home && find . \
               -type l  -exec bash -c 'echo -n {} "-> "; readlink "{}"' \; \
            -o -type d  -true  \
            -o          -print \
        | sed -e 's,^\./,,' | sort >"$actual")

    assert_output ''
    diff -u "$expected" "$actual"
}
