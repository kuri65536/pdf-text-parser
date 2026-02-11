##[ pp_parse_output_json.nim

License: MIT, see LICENSE
]##
import logging
import strutils

import pp_rules


const
    identifier* = "output_json"


proc parse_op*(val: string): OpOutputJson =
    ##[ parses the `val` as an `output_json` rule
    ]##
    let tmp = block:
        var tmp2: seq[string]
        for i in val.split(","): tmp2.add(i.strip())
        tmp2

    let ret = OpOutputJson(
        outs: @[],
    )

    for cell in tmp:
        if cell == "--spaces":
            ret.f_space = true; continue
        let parts = block:
            var parts2: seq[string]
            for i in cell.split(":"): parts2.add(i.strip())
            parts2
        debug("parse:json:", $parts)
        if len(parts) < 1:
            continue
        if len(parts) < 2:
            ret.outs.add(("", parts[0], ""))
            continue
        if len(parts) < 3:
            ret.outs.add((parts[0], parts[1], ""))
            continue
        ret.outs.add((parts[0], parts[1], parts[2]))
    return ret

