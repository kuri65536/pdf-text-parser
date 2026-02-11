##[ pp_parse_calc.nim

parse the calculate rule in the rules file.

License: MIT, see LICENSE
]##
import logging
import strutils

import pp_rules


const
    identifier* = "calc"


proc parse_calc_expr_tableget*(val: string): pp_rules.OpGet =
    ##[ parse an input string as the `pairs` rule name and its key value

        `test1[test2]` ... the `test1` rule and `test2` key

        for the rules:

        ```
        pairs = test1, ...
        extract = test3, ...
        calc = test3, add, test3, test1[test2]
        ```
    ]##
    let val = strutils.strip(val)
    if not strutils.contains(val, "["):
        return nil
    let tmp1 = strutils.split(val, "[")
    if len(tmp1) > 2:
        return nil
    if not strutils.contains(tmp1[1], "]"):
        return nil
    let tmp2 = strutils.split(tmp1[1], "]")
    if len(tmp2) > 2:
        return nil
    if len(tmp2[1]) != 0:
        return nil
    return OpGet(
        name_dest: "---", name_src: tmp1[0], key: tmp2[0],
    )


proc parse_calc_expr*(val: string): pp_rules.OpBase =
    ##[ parse an input string as the rule name.
    ]##
    let tmp = parse_calc_expr_tableget(val)
    if not isNil(tmp):
        return tmp
    return OpConvert(
        name: "---", name_src: val,
    )


proc parse_calc_op*(val: string): pp_rules.calc_kind =
    ##[ parse the operator string in the calc rule
    ]##
    let tmp = val.toLower().strip()
    if ["+", "add"].contains(tmp):
        return pp_rules.calc_kind.pck_add
    if ["-", "sub", "subtract"].contains(tmp):
        return pp_rules.calc_kind.pck_sub
    if ["*", "mul", "multiply"].contains(tmp):
        return pp_rules.calc_kind.pck_mul
    if ["&", "concat"].contains(tmp):
        return pp_rules.calc_kind.pck_concat
    if ["?", "if", "ternary"].contains(tmp):
        return pp_rules.calc_kind.pck_ternary
    raise newException(ValueError, "invalid calc string: " & val)


proc parse_op*(val: string): OpCalc =
    ##[ parses the `val` as the `calc` rule

        `calc = name, op, term1, term2, ...`
    ]##
    let tmp = pp_rules.split_to_cells(val)
    if len(tmp) < 3:
        return nil
    let k = try:               parse_calc_op(tmp[1])
            except ValueError: return nil
    var ret: seq[OpBase]
    for i in tmp[2 ..^ 1]:
        let tmp = parse_calc_expr(i)
        if not isNil(tmp):
            ret.add(tmp)
    if len(ret) < 1:
        error("rules:calc: can't find calc expressions: " & $tmp)
        return nil

    warn("rules:calc: parsed: " & $k & " terms:" & $len(ret))
    return OpCalc(name_dest: strutils.strip(tmp[0]),
                  calc: k,
                  exprs: ret)

