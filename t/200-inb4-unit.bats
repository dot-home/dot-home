load test_helper/bats-support/load
load test_helper/bats-assert/load

@test 'inb4_sort' {
    source bin/dot-home --define-functions-only
    inb4_sort 2.4 0.6 1.4 1.0
    assert_equal "${inb4_sorted[0]}" '1.0'
    assert_equal "${inb4_sorted[1]}" '2.4'
    assert_equal "${inb4_sorted[2]}" '1.4'
    assert_equal "${inb4_sorted[3]}" '0.6'
}
