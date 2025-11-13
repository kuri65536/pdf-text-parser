##[ pp_parse.nim

License: MIT, see LICENSE
]##
import logging
import strutils

import pp_rules


proc parse_op*(val: string): OpFormatCsv =
    ##[ parses the `val` as `extract` rule in a opt-val pair.
    ]##
    let tmp = block:
        var tmp2: seq[string]
        for i in val.split(","): tmp2.add(i.strip())
        tmp2

    let ret = OpFormatCsv(kind: pp_rules.operation_kind.ppk_csv, )
    for cell in tmp:
        let parts = block:
            var parts2: seq[string]
            for i in cell.split(":"): parts2.add(i.strip())
            parts2
        debug("parse:csv:", $parts)
        if len(parts) < 1:
            continue
        if len(parts) < 2:
            ret.outs.add((parts[0], ""))
            continue
        ret.outs.add((parts[0], parts[1]))
    return ret

