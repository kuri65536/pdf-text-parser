##[ pp_format.nim

License: MIT, see LICENSE
]##
import logging
import strutils


proc format_float*(fmt, src: string): string =
    ##[ format a string as the float text and convert it to the integer text
    ]##
    let src = src.replace(",", "")
    let fmt = fmt[0 ..^ 2]
    let n = try:   parseInt(fmt)
            except ValueError:
                error("format:float: can't parse the format ... " & fmt)
                0
    let val = try:   int(parseFloat(src) + 0.4)
              except ValueError:
                error("format:float: can't parse the value ... " & src)
                0
    if n < 1:
        return $val
    return strutils.align($val, n)


proc format*(fmt, src: string): string =
    ##[ format a string to the specific format `fmt`

        - "----" -> align to `len(fmt)`
        - "6"    -> align to `parseInt(fmt)`

        .. note:: todo ... specify the number type at format
    ]##
    if fmt.endsWith("f"):
        return format_float(fmt, src)
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

