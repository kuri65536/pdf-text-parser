##[ app_parse_get.nim

License: MIT, see LICENSE
]##
import logging

import pp_extracted
import pp_rules


proc convert*(op: pp_rules.OpGet,
            src: openarray[pp_extracted.Block]): pp_extracted.Block =
    ##[
    ]##
    warn("parse:get:enter for " & op.name_dest)
    let ret = pp_extracted.find_with_key(src, op.name_src, op.key)
    if isNil(ret):
        error("parse:get:specified is not found ... " & op.name_src &
              ", key:" & op.key)
        return nil
    warn("parse:get:got new block ... " & op.name_dest & " as " & ret.text)
    ret.name = op.name_dest
    return ret

