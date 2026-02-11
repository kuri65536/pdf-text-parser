##[ test_parse_calc1.nim

License: MIT, see LICENSE
]##
import logging

import ../src/pdf_text_parser/pp_conv_calc
import ../src/pdf_text_parser/pp_extracted
import ../src/pdf_text_parser/pp_parse_calc

block:
    logging.addHandler(logging.newConsoleLogger())
    logging.setLogFilter(lvlNotice)


block:
    let op = pp_parse_calc.parse_op("abc, concat, 1, 2")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "12", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("abc, concat, bcd, 2")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "dummy2", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("abc, concat, 1, bcd")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "1dummy", "wrong:'" & ans.text & "'"

