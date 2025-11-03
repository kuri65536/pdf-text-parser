##[ test_ini.nim

License: MIT, see LICENSE
]##
import streams
import tables

import ../src/pdf_text_parser/pp_inifile


## simple
block:
    let strm = newStringStream("""
        extract = a, 10, 10, 10, 10
    """)
    let tbl = load_ini(strm)
    assert tbl[""][0] == ("extract", "a, 10, 10, 10, 10")


## simple 2
block:
    let strm = newStringStream("""
        abc = 123
        def = 456
    """)
    let tbl = load_ini(strm)
    assert tbl[""][0] == ("abc", "123")
    assert tbl[""][1] == ("def", "456")


## empty
block:
    let strm = newStringStream("""
    """)
    let tbl = load_ini(strm)
    assert len(tbl) == 1
    assert len(tbl[""]) < 1


## section
block:
    let strm = newStringStream("""
        [aaa]

        [bbb]
    """)
    let tbl = load_ini(strm)
    assert len(tbl[""]) < 1
    assert len(tbl["aaa"]) < 1
    assert len(tbl["bbb"]) < 1


## combination
block:
    let strm = newStringStream("""

        0 = 1

        [aaa]
        a = 1
        aa = 1


        [bbb]

        bbb = 1

        bb = 1

        [aaa]
        aaa = 1
    """)

    let tbl = load_ini(strm)
    assert len(tbl[""]) == 1
    assert len(tbl["aaa"]) == 3, $tbl["aaa"]
    assert len(tbl["bbb"]) == 2


