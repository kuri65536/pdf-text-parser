##[ test_parse_calc2_3.nim

License: MIT, see LICENSE
]##
import logging

import ../src/pdf_text_parser/pp_extracted
import ../src/pdf_text_parser/pp_parse_calc
import ../src/pdf_text_parser/app_parse_calc

block:
    logging.addHandler(logging.newConsoleLogger())
    #ogging.setLogFilter(lvlNotice)
    logging.setLogFilter(lvlDebug)


## results are constants
block:
    let op = pp_parse_calc.parse_op("abc, ternary, test1 === test1, def, ghi")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "def", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("abc, ternary, test1 !== test1, def, ghi")
    let blks = [pp_extracted.Block(name: "bcd", text: "dummy")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "ghi", "wrong:'" & ans.text & "'"


## results are the variable and the contant
block:
    let op = pp_parse_calc.parse_op("abc, ternary, 1 >= 0, a_a, const1")
    let blks = [pp_extracted.Block(name: "a_a", text: "dummy")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "dummy", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("zzzz, ternary, 1 < 0, a_a, const1")
    let blks = [pp_extracted.Block(name: "a_a", text: "dummy")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "const1", "wrong:'" & ans.text & "'"


## results are the constant and the variable
block:
    let op = pp_parse_calc.parse_op("l_l, ?, a === a, 1, var3")
    let blks = [pp_extracted.Block(name: "var3", text: "100")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "1", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("l_l, ?, a !== a, 1, var3")
    let blks = [pp_extracted.Block(name: "var3", text: "100")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "100", "wrong:'" & ans.text & "'"


## results are the variables
block:
    let op = pp_parse_calc.parse_op("abc, ternary, 1 <== 2, var1, var2")
    let blks = [pp_extracted.Block(name: "var1", text: "this is variable 1"),
                pp_extracted.Block(name: "var2", text: "this is variable 2")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "this is variable 1", "wrong:'" & ans.text & "'"

block:
    let op = pp_parse_calc.parse_op("abc, ternary, 2 <== 1, var1, var2")
    let blks = [pp_extracted.Block(name: "var1", text: "this is variable 1"),
                pp_extracted.Block(name: "var2", text: "this is variable 2")]
    let ans = app_parse_calc.parse(op, blks)
    assert ans.text == "this is variable 2", "wrong:'" & ans.text & "'"

