load 'test-lib'

setup() {
    test_lib_setup
    export HOME=/dev/null
    source "$BATS_TEST_DIRNAME/../bin/dot-home-setup" --define-functions-only
}

@test "warn" {
    # Cannot use run because it combines stdout and stderr
    output=$(warn "world will end" 2>&1 >/dev/null)
    assert_output '.home WARNING: world will end'
}

compare() {
    [ -n "$compare_failures" ] || {
        echo >&2 "Must set compare_failures=0 before calling compare()"
        false; return
    }
    local actual="$1" expected="$2"
    [ "$actual" = "$expected" ] && return
    [ $compare_failures -eq 0 ] \
        && echo >&2 "Comparison failures (actual, expected)"
    compare_failures+=1
    printf >&2 "%-25s %s\n" "$actual" "$expected"
}

assert_compares() {
    [ $compare_failures -eq 0 ] && return
    echo >&2 "$compare_failures compare failures found."
    false
}

@test "canonicalize_dots" {

    local -i compare_failures=0         # lexically scoped
    check() { compare "$(canonicalize_dots "$1")" "$2"; }

    # Already canonical
    check   NN                          NN
    check   /NN                         /NN
    check   NN/bb/cc                    NN/bb/cc
    check   /NN/bb/cc                   /NN/bb/cc

    # Remove double-slashes
    check   //SS///b/c//d               /SS/b/c/d

    # Remove single dot components
    check   ./SD                        SD
    check   ././SD                      SD
    check   /./SD                       /SD
    check   /SD/././bb                  /SD/bb
    check   ./SD/./bar/././.            SD/bar
    check   ./SD/./bar/./././           SD/bar/

    # All dot-dots reoved
    check   /SD/./.././AA               /AA
    check   /aa/.../../bb               /aa/bb
    check   /bb/../AA                   /AA
    check   /a.a/../AA                  /AA
    check   /aa/../bb/../cc/../AA       /AA
    check   /bb/AA/cc/dd/../..          /bb/AA
    check   /aa/bb/cc/../../AA          /aa/AA

    check   aa/../bb                    bb
    check   aa/../bb/../cc/../dd        dd
    check   aa/bb/cc/dd/../..           aa/bb
    check   aa/bb/cc/../../dd           aa/dd

    check   ../aa/bb/../cc              ../aa/cc

    check   /aa/..                      /
    check   /aa/../..                   /..
    check   /aa/../../..                /../..
    check   /aa/../../bb                /../bb

    check   /aa/.../bb                  /aa/.../bb
    check   /aa/..bb                    /aa/..bb

    check   /a/../b/                    /b/

    #c '')"                     ''
    #c 'a b/c d/../e f')"       'a b/e f'

    assert_compares

    # ??? assert_equal $(c aa/..)                    .
}

@test "set_dest_target" {
    local src dest target

    set_dest_target           'a/bin'
    assert_equal    "$dest"     'bin'
    assert_equal    "$target"   '.home/a/bin'

    set_dest_target           'a/bin/file'
    assert_equal    "$dest"     'bin/file'
    assert_equal    "$target"   '../.home/a/bin/file'

    set_dest_target         'a b/bin/dir/sub dir/sub file'
    assert_equal    "$dest"     'bin/dir/sub dir/sub file'
    assert_equal    "$target"   '../../../.home/a b/bin/dir/sub dir/sub file'

    set_dest_target         'a/dot/file'
    assert_equal    "$dest"     '.file'
    assert_equal    "$target"   '.home/a/dot/file'

    set_dest_target         'a/dot/b/c/d/file'
    assert_equal    "$dest"     '.b/c/d/file'
    assert_equal    "$target"   '../../../.home/a/dot/b/c/d/file'
}
