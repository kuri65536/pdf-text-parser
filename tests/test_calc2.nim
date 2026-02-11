##[ test_parse_calc2.nim

License: MIT, see LICENSE
]##
import logging

import ../src/pdf_text_parser/pp_conv_calc
import ../src/pdf_text_parser/pp_extracted
import ../src/pdf_text_parser/pp_parse_calc

block:
    logging.addHandler(logging.newConsoleLogger())
    #ogging.setLogFilter(lvlNotice)
    logging.setLogFilter(lvlDebug)


block:
    let op = pp_parse_calc.parse_op("abc, ?, 1 > 2, 3, 4")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "4", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("abc, ternary, 1 < 2, 3, 4")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "3", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("abc, ternary, bcd == dummy, def, ghi")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "def", "wrong:'" & ans.text & "'"



