##[ app_parse.nim

License: MIT, see LICENSE
]##
import logging

import pp_conv_calc
import pp_conv_datetime
import pp_conv_get
import pp_conv_string
import pp_extracted
import pp_rules


proc parse_rule_parse(op: pp_rules.OpBase,
                      src: openarray[pp_extracted.Block]): pp_extracted.Block =
    ##[
    ]##
    let opprs = pp_rules.OpConvert(op)
    let blk = pp_extracted.find(src, opprs.name_src)
    if len(blk.name) < 1:
        return pp_extracted.Block()
    let tmp2 = case opprs.typ:
        of pp_rules.parse_kind.prk_string:
            let tmp = pp_conv_string.parse(opprs.fmt_parse, blk.text)
            warn("parse:parse:string:got " & blk.text & " => " & tmp)
            pp_conv_string.format(opprs.fmt_store, tmp)
        of pp_rules.parse_kind.prk_datetime:
            warn("parse:parse:datetime:got " & blk.text)
            let tmp = pp_conv_datetime.parse(opprs.fmt_parse, blk.text)
            warn("parse:parse:datetime:got " & blk.text & " => " & $tmp)
            pp_conv_datetime.format(opprs.fmt_store, tmp)
    result = pp_extracted.Block(
        name: opprs.name,
        text: tmp2,
    )


proc parse_rule(op: pp_rules.OpBase,
                src: openarray[pp_extracted.Block]): pp_extracted.Block =
    ##[
    ]##
    warn("parse:a rule ... " & $type(op))
    if op of pp_rules.OpCalc:
        return pp_conv_calc.convert(OpCalc(op), src)
    if op of pp_rules.OpGet:
        return pp_conv_get.convert(OpGet(op), src)
    if op of pp_rules.OpConvert:
        let tmp = parse_rule_parse(op, src)
        if len(tmp.name) > 0:
            return tmp
    else:
        discard

    result = pp_extracted.Block(
        name: "",
        text: "",
    )


proc parse*(rules: openarray[pp_rules.Rule],
            src: openarray[pp_extracted.Block]): seq[pp_extracted.Block] =
    ##[
    ]##
    debug("parse:enter... " & $len(src) & " with " & $len(rules))
    result = @[]
    for blk in src:
        result.add(blk)

    for rule in rules:
        for op in rule.ops:
            let blk_new = parse_rule(op, result)
            if isNil(blk_new):
                continue
            if len(blk_new.name) < 1:
                continue
            result.add(blk_new)

