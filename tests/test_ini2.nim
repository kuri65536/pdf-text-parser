##[ test_ini2.nim

License: MIT, see LICENSE
]##
import streams
import strutils
import tables

import ../src/pdf_text_parser/pp_inifile


## multi-lines
block:
    let strm = newStringStream("""
        abc = 1,
              2,
              3,

              4
    """)
    let tbl = load_ini(strm)
    assert len(tbl) == 1
    let (opt, val) = tbl[""][0]
    assert opt == "abc", opt
    var tmp: seq[string]
    for i in val.split(","):
        tmp.add(i.strip)
    assert tmp.join(",") == "1,2,3,", "=>" & $tmp

