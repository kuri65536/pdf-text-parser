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


## compare constants
block:
    let op = pp_parse_calc.parse_op("abc, ternary, test1 === test1, def, ghi")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "def", "wrong:'" & ans.text & "'"


## compare a variable vs a constant
block:
    let op = pp_parse_calc.parse_op("abc, ternary, bcd !== dummy, def, ghi")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "ghi", "wrong:'" & ans.text & "'"


## compare a constant vs a variable
block:
    let op = pp_parse_calc.parse_op("nnn, ternary, abcd >== v3r, 1, 2")
    let blks = [pp_extracted.Block(name: "v3r", text: "abcde")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "2", "wrong:'" & ans.text & "'"


## compare variables
block:
    let op = pp_parse_calc.parse_op("abc, ternary, var1 <== var2, res1, res2")
    let blks = [pp_extracted.Block(name: "var1", text: "aaa"),
                pp_extracted.Block(name: "var2", text: "aab")]
    let ans = pp_conv_calc.convert(op, blks)
    assert ans.text == "res1", "wrong:'" & ans.text & "'"

