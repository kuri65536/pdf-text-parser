##[ pp_eval_calc_concat.nim

run the calculation from the extracted results.

License: MIT, see LICENSE
]##
import logging

import pp_eval_calc
import pp_extracted
import pp_rules


proc eval*(src: openarray[pp_extracted.Block],
           exprs: seq[pp_rules.OpBase]): string =
    ##[ evaluate the `OpCalc` `concat` expressions.
    ]##
    result = ""
    for i in exprs:
        let (n, k, res) = pp_eval_calc.eval_calc_expr(src, i)
        if len(res) < 1:
            error("eval:calc:concat: term was ignored: " & $type(i))
            continue
        if len(k) > 1:
            debug("eval:calc:concat: value from `get`: " & n & "-" & k)
        elif len(n) > 1:
            debug("eval:calc:concat: value from `parse`: " & n)
        else:
            debug("eval:calc:concat: value not parsed: " & res)
        result &= res
    return result

