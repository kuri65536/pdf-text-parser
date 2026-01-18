##[ app_parse.nim

License: MIT, see LICENSE
]##
import app_parse_datetime
import app_parse_string
import pp_extracted
import pp_rules


proc parse_rule_parse(op: pp_rules.OpBase,
                      src: openarray[pp_extracted.Block]): pp_extracted.Block =
    ##[
    ]##
    let opprs = pp_rules.OpParse(op)
    let blk = pp_extracted.find(src, opprs.name_src)
    if len(blk.name) < 1:
        return pp_extracted.Block()
    let tmp2 = case opprs.typ:
        of pp_rules.parse_kind.prk_string:
            let tmp = app_parse_string.parse(opprs.fmt_parse, blk.text)
            app_parse_string.format(opprs.fmt_store, tmp)
        of pp_rules.parse_kind.prk_datetime:
            let tmp = app_parse_datetime.parse(opprs.fmt_parse, blk.text)
            app_parse_datetime.format(opprs.fmt_store, tmp)
    result = pp_extracted.Block(
        name: opprs.name,
        text: tmp2,
    )


proc parse_rule(op: pp_rules.OpBase,
                src: openarray[pp_extracted.Block]): pp_extracted.Block =
    ##[
    ]##
    if op of pp_rules.OpParse:
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
    result = @[]
    for blk in src:
        result.add(blk)

    for rule in rules:
        for op in rule.ops:
            let blk_new = parse_rule(op, result)
            if len(blk_new.name) > 0:
                result.add(blk_new)

