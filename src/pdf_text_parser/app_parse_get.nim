##[ app_parse_get.nim

License: MIT, see LICENSE
]##
import logging

import pp_extracted
import pp_rules


proc parse*(op: pp_rules.OpGet,
            src: openarray[pp_extracted.Block]): pp_extracted.Block =
    ##[
    ]##
    warn("parse:get:enter for " & op.name_dest)
    for blk in src:
        if blk.name != op.name_src:
            continue
        if not(blk of BlockPairs):
            error("parse:get:specified is not a pairs block ... " & blk.name)
            continue
        let tmp = BlockPairs(blk)
        for (k, v) in tmp.pairs:
            if k != op.key:
                continue
            warn("parse:get:got new block ... " & op.name_dest & " as " & v)
            return pp_extracted.Block(
                name: op.name_dest, text: v,
            )
        error("parse:get:the table does not have key ... " & op.key)
        break
    error("parse:get:can't find the table ... " & op.name_src)
    return nil

