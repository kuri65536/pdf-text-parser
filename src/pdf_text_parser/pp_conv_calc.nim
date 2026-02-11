##[ app_parse_calc.nim

run the calculation from the extracted results.

License: MIT, see LICENSE
]##
import math
import logging
import strutils

import pp_eval_calc_concat
import pp_eval_calc_ternary
import pp_extracted
import pp_rules


proc parse_value*(src: pp_extracted.Block): float =
    ##[ parse the value in the `Block`, it must be the float text.
    ]##
    result = block:
        try:
            let tmp = strutils.replace(src.text, ",", "")
            parseFloat(tmp)
        except ValueError:
            NaN


proc convert*(op: pp_rules.OpCalc,
            src: openarray[pp_extracted.Block]): pp_extracted.Block =
    ##[ calculate the specified `Block` values

        returns the new `Block` with the evaluated value.
    ]##
    warn("parse:calc:enter for: " & op.name_dest)
    var ret = case op.calc:
              of calc_kind.pck_add: 0.0
              of calc_kind.pck_sub: 0.0
              of calc_kind.pck_mul: 1.0
              of calc_kind.pck_concat:
                let tmp = pp_eval_calc_concat.eval(src, op.exprs)
                return pp_extracted.Block(name: op.name_dest, text: tmp)
              of calc_kind.pck_ternary:
                let tmp = pp_eval_calc_ternary.eval(src, op.exprs)
                return pp_extracted.Block(name: op.name_dest, text: tmp)
    for i in op.exprs:
        let (n, k, blk) = block:
            if i of OpConvert:
                let name = OpConvert(i).name_src
                (name, "", pp_extracted.find(src, name))
            elif i of OpGet:
                let op = OpGet(i)
                let (name, key) = (op.name_src, op.key)
                (name, key, pp_extracted.find_with_key(src, name, key))
            else:
                ("", "", nil)
        if isNil(blk) or len(blk.name) < 1:
            error("parse:calc:can't find the value: " & n & "-" & k)
            continue
        let v = parse_value(blk)
        if math.isNaN(v):
            continue
        warn("parse:calc:got " & $v & "for " & n & "-" & k)
        case op.calc:
        of calc_kind.pck_add: ret += v
        of calc_kind.pck_sub: ret -= v
        of calc_kind.pck_mul: ret *= v
        else:                 discard
    return pp_extracted.Block(
        name: op.name_dest, text: $ret
    )

