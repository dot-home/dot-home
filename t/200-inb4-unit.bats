load test_helper/bats-support/load
load test_helper/bats-assert/load

@test 'inb4_sort' {
    source bin/dot-home-setup --define-functions-only
    inb4_sort 2.4 0.6 1.4 1.0
    assert_equal "${inb4_sorted[0]}" '1.0'
    assert_equal "${inb4_sorted[1]}" '2.4'
    assert_equal "${inb4_sorted[2]}" '1.4'
    assert_equal "${inb4_sorted[3]}" '0.6'
}

@test inb4_find_comment_char {
    source bin/dot-home-setup --define-functions-only

    # Default comment char
    inb4_find_comment_char </dev/null
    assert_equal "$inb4_comment_char" '#'

    # needs to take the output of `head -n 5 "${inb4_outputs[@]}"`, find
    # the first comment-char-setting line (if any) and set a shell variable
    # with the comment char

    inb4_find_comment_char <<.
==> a/filename <==
# none of
# these are
# comment
# setting
# lines

==> another/filename <==
" foobar
:command
" :inb4:
" Since we now have the comment character, the following is a no-op
# :inb4:

.
    assert_equal "$inb4_comment_char" '"'
}
