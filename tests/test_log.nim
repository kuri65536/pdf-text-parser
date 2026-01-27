##[ test_log.nim

License: MIT, see LICENSE
]##
import logging
import ../src/pdf_text_parser/options


## set loglevel to 0
block:
    for i in countDown(7, 0):
        echo("log-level will be set to " & $i)
        discard options.options(@["-V", $i])
        debug("debug")
        info("info")
        notice("notice")
        warn("warn")
        error("error")
        fatal("fatal")


