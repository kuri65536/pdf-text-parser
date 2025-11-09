##[ test_parse_string3.nim

License: MIT, see LICENSE
]##
import logging

import ../src/pdf_text_parser/app_parse_string

block:
    logging.addHandler(logging.newConsoleLogger())
    logging.setLogFilter(lvlNotice)


block:
    let (fmt, src) = ("%a%b%c%", "test")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "test", "wrong:'" & ans & "'"


block:
    let (fmt, src) = ("/a/b/c/d/", "test2")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "test2", "wrong:'" & ans & "'"


block:
    let (fmt, src) = ("/abcd/", "test3")
    let ans = app_parse_string.parse(fmt, src)
    assert ans == "test3", "wrong:'" & ans & "'"

