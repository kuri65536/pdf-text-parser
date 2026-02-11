##[ test_output_json1.nim

License: MIT, see LICENSE
]##
import streams

import ../src/pdf_text_parser/app_output
import ../src/pdf_text_parser/pp_extracted
import ../src/pdf_text_parser/pp_rules


## simple
block:
    let blks = @[pp_extracted.Block(name: "a", text: "1"),
                 pp_extracted.Block(name: "b", text: "2"),
                 ]
    let rules: seq[Rule] = @[pp_rules.Rule(
        ops: @[OpBase(), OpOutputJson(
            outs: @[("a", "c", ""),
                    ("b", "d", "")]
        )]
    )]
    var strm = newStringStream()
    app_output.output(strm, rules, blks, {})
    strm.setPosition(0)
    let s = strm.readAll()
    assert s == """{"c":"1","d":"2"}""", "error: " & s


## with spaces
block:
    let blks = @[pp_extracted.Block(name: "abc", text: "one two three"),
                 pp_extracted.Block(name: "eee", text: "nothing"),
                 ]
    let rules: seq[Rule] = @[pp_rules.Rule(
        ops: @[OpBase(), OpOutputJson(
            f_space: true,
            outs: @[("abc", "c", ""),
                    ("def", "not found", "")]
        )]
    )]
    var strm = newStringStream()
    app_output.output(strm, rules, blks, {})
    strm.setPosition(0)
    let s = strm.readAll()
    assert s == """{
  "c": "one two three",
  "not found": ""
}""", "error: " & s

