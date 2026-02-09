##[ pp_eval_calc_ternary.nim

evaluate the ternary operator in the `calc` operation.

License: MIT, see LICENSE
]##
import logging
import re
import strutils

import pp_eval_calc
import pp_extracted
import pp_rules


proc eval_calc_cond_split(expr: string): tuple[op, l, r: string] =
    ##[ split the expr string to terms:

        `a > b => (">", "a", "b")`
    ]##
    let op0 = re.findAll(expr, re"[<>=!]+")
    if len(op0) < 1:
        error("eval:calc:cond: can't eval the expr: " & expr)
        return ("", "", "")
    let opr = op0[0]
    let tmp = strutils.split(expr, opr)
    let tmp0 = tmp[0].strip()
    let tmp1 = strutils.join(tmp[1 ..^ 1], opr).strip()
    debug("eval:calc:cond: op=>'" & opr & "' " & tmp0 & " vs " & tmp1)
    return (opr, tmp0, tmp1)


proc eval_calc_cond_string(op, l, r: string): tuple[p, f: bool] =
    ##[
        returns: p ... proceed, f ... result
    ]##
    case op:
    of "===": return (true, l == r)
    of "!==": return (true, l != r)
    of "<==": return (true, l <= r)
    of ">==": return (true, l >= r)
    else:     discard
    return (false, false)


proc eval_calc_cond_num*(op, l, r: string): tuple[p, f: bool] =
    ##[
        returns: p ... proceed, f ... result
    ]##
    proc parse_num(s: string): float =
        strutils.parseFloat(s)

    let (l, r) = try:
            let tmpl = parse_num(l)
            let tmpr = parse_num(r)
            (tmpl, tmpr)
        except ValueError:
            (0.0, 0.0)

    case op:
    of "==": return (true, l == r)
    of "=":  return (true, l == r)
    of "!=": return (true, l != r)
    of "<>": return (true, l != r)
    of "<":  return (true, l < r)
    of "<=": return (true, l <= r)
    of ">":  return (true, l > r)
    of ">=": return (true, l >= r)
    else:    discard
    return (false, false)


proc eval_calc_cond*(src: openarray[pp_extracted.Block],
                      cond_expr: pp_rules.OpBase): bool =
    ##[ evaluate the condition expression
    ]##
    let (op, ls, rs) = eval_calc_cond_split(OpParse(cond_expr).name_src)
    if op == "<>" and rs == "\"\"":
        let blk = pp_extracted.find(src, ls)
        return len(blk.name) > 0
    let (l, r) = (pp_eval_calc.eval_calc_str(src, ls),
                  pp_eval_calc.eval_calc_str(src, rs))
    block:
        let (p, f) = eval_calc_cond_string(op, l, r)
        if p:
            return f
    block:
        let (p, f) = eval_calc_cond_num(op, l, r)
        if p:
            return f
    error("eval:calc:cond: can't eval '" & op & "' => " & l & "," & r)
    return false


proc eval*(src: openarray[pp_extracted.Block],
           exprs: seq[pp_rules.OpBase]): string =
    ##[ evaluate the `OpCalc` `?` or `ternary` expressions.

        - `exprs[0]` ... the condition
        - `exprs[1]` ... result when the condition is true
        - `exprs[2]` ... result when the condition is false
    ]##
    let cond = eval_calc_cond(src, exprs[0])

    let exp = if cond: exprs[1] else: exprs[2]
    let (n, k, res) = pp_eval_calc.eval_calc_expr(src, exp)
    if len(res) < 1:
        error("eval:calc:ternary: invalid 2 or 3: " & $type(exp))
        return ""
    if len(k) > 1:
        debug("eval:calc:ternary: value from `get`: " & n & "-" & k)
    elif len(n) > 1:
        debug("eval:calc:ternary: value from `parse`: " & n)
    else:
        debug("eval:calc:ternary: value not parsed: " & res)
    return res

