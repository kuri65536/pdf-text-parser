##[ pp_parse_pairs.nim

License: MIT, see LICENSE
]##
import logging
import math
import strutils

import pp_rules


const
    identifier* = "pairs"


proc parse_base_diff*(val: string): float =
    ##[ parse an input string as base line difference value.
    ]##
    let tmp = block:
        if strutils.startsWith(val, "bd:"):          val[3 ..^ 1]
        elif strutils.startsWith(val, "base_diff:"): val[9 ..^ 1]
        else:
            return NaN
    try:
        let v = parseFloat(tmp)
        if v < 0: return -v
        return v
    except ValueError:
        return NaN


proc parse_area_def*(val: string): PairArea =
    ##[ parse an input string as the definition of the pair data area
    ]##
    const fallback = (NaN, NaN, NaN, NaN)
    let tmp = strutils.split(val, ":")
    if len(tmp) < 4:
        return fallback

    proc p(src: string): float =
        try:
            return parseFloat(src)
        except ValueError:
            error("rule:parse:invalid data for area => '" & src & "'")
            return NaN

    let x1 = p(tmp[0])
    let w1 = p(tmp[1])
    let x2 = p(tmp[2])
    let w2 = p(tmp[3])
    return (x1, w1, x2, w2)


proc parse_op*(val: string): OpPairs =
    ##[ parses the `val` as `pairs` rule in a opt-val pair.
    ]##
    let tmp = pp_rules.split_to_cells(val)
    if len(tmp) < 2:
        return nil
    var tmp_bd: float = 1.0
    var tmp_area: seq[PairArea]
    for i in tmp[1 ..^ 1]:
        let bd = parse_base_diff(i)
        if not math.isNaN(bd):
            tmp_bd = bd; continue
        let area_def = parse_area_def(i)
        if not math.isNaN(area_def.x1):
            tmp_area.add(area_def)
    if len(tmp_area) < 1:
        error("rules:pairs: can't find area defs: " & $tmp)
        return nil

    warn("rules:pairs: defs: " & $tmp_area)
    return OpPairs(name: strutils.strip(tmp[0]),
                   areas: tmp_area,
                   base_diff: tmp_bd)

