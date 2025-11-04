##[ test_ini3.nim

License: MIT, see LICENSE
]##
import streams
import strutils
import tables

import ../src/pdf_text_parser/pp_inifile


## comment ... simple
block:
    let strm = newStringStream("""
        ; simple
        some_simple_opt = val1
    """)
    let tbl = load_ini(strm)
    assert len(tbl) == 1
    let (opt, val) = tbl[""][0]
    assert opt == "some_simple_opt", opt
    assert val == "val1", "=>" & val


## comment ... simple 2
block:
    let strm = newStringStream("""
        # simple
        __aaa = __bbb
    """)
    let tbl = load_ini(strm)
    assert len(tbl) == 1
    let (opt, val) = tbl[""][0]
    assert opt == "__aaa", opt
    assert val == "__bbb", "=>" & val

