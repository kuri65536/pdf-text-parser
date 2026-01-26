##[ pp_eval_calc.nim

evaluate the input expressions for the calculation results.

License: MIT, see LICENSE
]##
import logging

import pp_extracted
import pp_rules


proc eval_calc_get*(src: openarray[pp_extracted.Block], exp: pp_rules.OpBase
                    ): tuple[name, key: string, blk: pp_extracted.Block] =
    ##[ get the expression `exp` from the `src`
    ]##
    if exp of OpParse:
        let name = OpParse(exp).name_src
        return (name, "", pp_extracted.find(src, name))

    if exp of OpGet:
        let op = OpGet(exp)
        let (name, key) = (op.name_src, op.key)
        return (name, key, pp_extracted.find_with_key(src, name, key))

    return ("", "", nil)


proc eval_calc_expr*(src: openarray[pp_extracted.Block], exp: pp_rules.OpBase
                     ): tuple[name, key, res: string] =
    ##[ evaluate the input expression as `exp`
    ]##
    let (n, k, blk) = eval_calc_get(src, exp)
    if not isNil(blk) and len(blk.name) > 0:
        return (n, k, blk.text)

    if exp of OpParse:
        let tmp = OpParse(exp)
        return ("", "", tmp.name_src)
    elif exp of OpGet:
        let tmp = OpGet(exp)
        warn("parse:calc:eval_expr: key of the `get` ignored: " & tmp.key)
        return ("", "", tmp.name_src)
    return ("", "", "")


proc eval_calc_str*(src: openarray[pp_extracted.Block], exp: string): string =
    ##[ evaluate the input expression as `exp`
    ]##
    let (n, k, blk) = eval_calc_get(src, OpParse(name_src: exp))
    discard n
    discard k
    if isNil(blk) or len(blk.text) < 1:
        return exp
    return blk.text

