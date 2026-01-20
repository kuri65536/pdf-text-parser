##[ pp_rulesfile.nim

License: MIT, see LICENSE
]##
import logging
import os
import std/paths
import streams
import strutils
import tables

import pp_inifile
import pp_rules
import pp_parse_calc
import pp_parse_expand
import pp_parse_pairs
import pp_parse_parse
import pp_parse_output


proc parse_extract_op(val: string): pp_rules.OpExtract =
    ##[ parses the `val` as `extract` rule in a opt-val pair.
    ]##
    debug("rules:extract: parse " & val)
    let tmp = pp_rules.split_to_cells(val)
    if len(tmp) < 1:
        error("rules:extract: ignored the invalid line: " & val); return nil
    let name = tmp[0]
    if len(tmp) < 5:
        error("rules:extract: ignored the invalid rect: " & val); return nil
    proc err(msg: string): OpExtract =
        error("rules:extract: error with " & msg); return nil
    let x = try:   parseFloat(tmp[1])
            except ValueError: return err("x => " & tmp[1])
    let y = try:   parseFloat(tmp[2])
            except ValueError: return err("y => " & tmp[2])
    let w = try:   parseFloat(tmp[3])
            except ValueError: return err("w => " & tmp[3])
    let h = try:   parseFloat(tmp[4])
            except ValueError: return err("h => " & tmp[4])

    info("rules:extract: new rule " & name & "=" & $x & $y & $w & $h)
    return OpExtract(name: name,
                     x: x, y: y, w: w, h: h)


proc parse_get_op(val: string): pp_rules.OpGet =
    ##[ parses the `val` as `extract` rule in a opt-val pair.
    ]##
    debug("rules:parse:get: " & val)
    let tmp = pp_rules.split_to_cells(val)
    if len(tmp) < 1:
        error("rules:parse:get: ignored the invalid line: " & val); return nil
    let name1 = tmp[0].strip()
    if len(tmp) < 2:
        error("rules:parse:get: ignored the invalid : " & val); return nil
    let name2 = tmp[1].strip()
    if len(tmp) < 3:
        error("rules:parse:get: ignored the invalid : " & val); return nil
    let name3 = tmp[2].strip()

    info("rules:parse:get: " & name1 & " <= " & name2 & "['" & name3 & "']")
    return OpGet(name_dest: name1,
                 name_src: name2, key: name3)


proc parse_op(tbl: SectionTable, key, val: string): pp_rules.OpBase =
    ##[ parses 1 rule from a key and val pair.
    ]##
    debug("rules:extract: parse " & key)
    case key.strip().toLower():
    of pp_parse_expand.identifier:
        return pp_parse_expand.parse_op(val)
    of "calc":
        return pp_parse_calc.parse_op(val)
    of "extract":
        return parse_extract_op(val)
    of "get":
        return parse_get_op(val)
    of "pairs":
        return pp_parse_pairs.parse_op(val)
    of "parse":
        return pp_parse_parse.parse_op(val)
    of "output_csv":
        return pp_parse_output.parse_op(val)
    else:
        error("rules:ignored the invalid key: ", $key, " and its value", $val)


proc parse_expand*(tbl: SectionTable, op: pp_rules.OpBase
                   ): seq[pp_rules.OpBase] =
    ##[
    ]##
    if not (op of OpExpand):
        return @[op]
    let ex = OpExpand(op)
    for (key, val) in tbl[ex.section]:
        let op2 = parse_op(tbl, key, val)
        let ops_sub = parse_expand(tbl, op2)
        error("rules:parse:expand-exp " & $len(ops_sub))
        result.add(ops_sub)
    error("rules:parse:expand-ret " & $len(result))
    return result


proc parse_rule*(tbl: SectionTable, section: string): Rule =
    ##[
        - parse the global section.
    ]##
    if not tbl.contains(section):
        error("rules:load: can't find the specified section: " & section)
        return pp_rules.Rule(name: "")
    debug("rules:parse: " & $tbl)
    var ops: seq[pp_rules.OpBase]
    for (key, val) in tbl[section]:
        let op = parse_op(tbl, key, val)
        let ops_sub = parse_expand(tbl, op)
        debug("rules:parse: add new rule: " & $len(ops_sub))
        ops.add(ops_sub)
    return pp_rules.Rule(
        page: -1, name: if len(section) < 1: "__global__" else: section,
        ops: ops,
    )


proc split_name_and_section*(src: string): tuple[name: Path, section: string] =
    ##[
    ]##
    let tmp = src.split(":")
    let sec = if len(tmp) > 1: tmp[1] else: ""
    let path = Path(tmp[0]).expandTilde()
    if not os.fileExists(path.string):
        return (Path(""), "")
    return (path, sec)


proc load*(path: Path, section: string): Rule =
    ##[
    ]##
    let strm = newFileStream(path.string, fmRead)
    defer: strm.close()
    let tbl = load_ini(strm)
    if len(tbl) < 1:
        error("rules:load: can't load ini contents")
        return Rule(name: "")
    debug("rules:parse: " & $tbl)
    return parse_rule(tbl, section)

