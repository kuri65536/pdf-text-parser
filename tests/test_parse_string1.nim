##[ test_parse_string1.nim

License: MIT, see LICENSE
]##
import ../src/pdf_text_parser/app_parse_string


## case 1: just %s or the null string.
block:
    let (fmt, src) = ("%s", "asdkfjkaf")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "asdkfjkaf", "wrong:'" & ans & "'"
block:
    let (fmt, src) = ("", "234567")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "234567", "wrong:'" & ans & "'"


## case 2: %s with the prefix
block:
    let (fmt, src) = ("abc%s", "abc1")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "1", "wrong:'" & ans & "'"


## case 3: %s with the suffix
block:
    let (fmt, src) = ("%s$33", "abcdef$33")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "abcdef", "wrong:'" & ans & "'"


## case 4: %s inside text
block:
    let (fmt, src) = ("---%s---", "---123---")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "123", "wrong:'" & ans & "'"


