##[ test_parse_string2.nim

License: MIT, see LICENSE
]##
import logging

import ../src/pdf_text_parser/pp_conv_string

block:
    logging.addHandler(logging.newConsoleLogger())
    logging.setLogFilter(lvlNotice)


## case 1: %1%2%g
block:
    let (fmt, src) = ("%-%3%g", "12-45-78-AB")
    let ans = pp_conv_string.parse(fmt, src)
    assert ans == "123453783AB", "wrong:'" & ans & "'"


## case 2: %1%2%
block:
    let (fmt, src) = ("%---%1%", "0---2345---78")
    let ans = pp_conv_string.parse(fmt, src)
    assert ans == "012345---78", "wrong:'" & ans & "'"


## case 3: %12%%34%2%
block:
    let (fmt, src) = ("#-##-#1#", "0-#-2345")
    let ans = pp_conv_string.parse(fmt, src)
    assert ans == "012345", "wrong:'" & ans & "'"


## case 4: %12%%34%2%
block:
    let (fmt, src) = ("#-##-#1#", "0-#-2345")
    let ans = pp_conv_string.parse(fmt, src)
    assert ans == "012345", "wrong:'" & ans & "'"

