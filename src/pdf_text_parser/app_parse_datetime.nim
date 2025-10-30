##[ app_parse_datetime.nim

License: MIT, see LICENSE
]##
import logging
import strutils
import times


proc parse*(fmt, src: string): times.DateTime =
    ##[
    ]##
    if fmt == "y年m月d日":
        debug("parse:parse...", fmt, src)
        let (y, md) = block:
            let tmp = src.split("年")
            (parseInt(tmp[0]), tmp[1])
        debug("parse:parse...", y, md)
        let (m, ds) = block:
            let tm2 = md.split("月")
            (parseInt(tm2[0]), tm2[1])
        let d = block:
            let tm3 = ds.split("日")
            parseInt(tm3[0])
        return times.dateTime(y, Month(m), d, 0, 0, 0)


proc format*(fmt: string, src: DateTime): string =
    ##[
    ]##
    return times.format(src, fmt)

