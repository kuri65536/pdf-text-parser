##[ pp_parse_output_xml.nim

License: MIT, see LICENSE
]##
import logging
import strutils

import pp_rules


const
    identifier* = "output_xml"


proc parse_op*(val: string): OpOutputXml =
    ##[ parses the `val` as `extract` rule in a opt-val pair.
    ]##
    let tmp = block:
        var tmp2: seq[string]
        for i in val.split(","): tmp2.add(i.strip())
        tmp2

    let ret = OpOutputXml(
        name: tmp[0],
        outs: @[],
    )

    for cell in tmp[1 ..^ 1]:
        let parts = block:
            var parts2: seq[string]
            for i in cell.split(":"): parts2.add(i.strip())
            parts2
        debug("parse:csv:", $parts)
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

