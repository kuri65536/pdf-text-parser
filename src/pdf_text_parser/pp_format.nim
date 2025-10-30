##[ pp_format.nim

License: MIT, see LICENSE
]##
import logging
import strutils


proc format*(fmt, src: string): string =
    ##[ format a string to the specific format `fmt`

        - "----" -> align to `len(fmt)`
        - "6"    -> align to `parseInt(fmt)`

        .. note:: todo ... specify the number type at format
    ]##
    let src = src.replace(",", "")
    debug("output:csv:enter... ", src, ", ", fmt)
    if len(fmt) < 1:
        return src
    if len(strutils.replace(fmt, "-", "")) > 0:
        discard
    elif len(src) < 1:
        debug("no-value, output the format:", fmt)
        return fmt
    else:
        debug("value:", src, ", with:", fmt)
        return strutils.align(src, len(fmt))
    let n = try:               parseInt(fmt)
            except ValueError: 9999
    if n != 9999:
        return strutils.align(src, n)
    return fmt

