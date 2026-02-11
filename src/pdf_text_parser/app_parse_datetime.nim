##[ app_parse_datetime.nim

License: MIT, see LICENSE
]##
import logging
import strutils
import times


proc parse*(fmt, src: string): times.DateTime =
    ##[
    ]##
    debug("parse:datetime: " & src & " as " & fmt)
    let fmt = fmt.strip()
    if len(fmt) > 30:
        error("parse:datetime: can't pass the format over 30 characters:" & fmt)
        return times.now()
    try:
        return times.parse(src, fmt)
    except TimeParseError:
        error("parse:datetime: can't parse: " & fmt & "," & src &
              "=>" & getCurrentExceptionMsg())
        return times.now()
    except TimeFormatParseError:
        error("parse:datetime: format error: " & fmt & "," & src &
              "=>" & getCurrentExceptionMsg())
        return times.now()


proc format*(fmt: string, src: DateTime): string =
    ##[
    ]##
    return times.format(src, fmt)

