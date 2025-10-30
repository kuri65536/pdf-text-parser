##[ pp_rulesfile.nim

License: MIT, see LICENSE
]##
import logging
import os
import std/paths
import strutils
import tables

import pp_inifile
import pp_rules
import pp_parse_parse
import pp_parse_output


proc parse_extract_as_seq(val: string): seq[Rule] =
    ##[ parses the `val` as `extract` rule in a opt-val pair.
    ]##
    debug("rules:extract: parse " & val)
    let tmp = pp_rules.split_to_cells(val)
    if len(tmp) < 1:
        error("rules:extract: ignored the invalid line: " & val); return @[]
    let name = tmp[0]
    if len(tmp) < 5:
        error("rules:extract: ignored the invalid rect: " & val); return @[]
    proc err(msg: string): seq[Rule] =
        error("rules:extract: error with " & msg); return @[]
    let x = try:   parseFloat(tmp[1])
            except ValueError: return err("x => " & tmp[1])
    let y = try:   parseFloat(tmp[2])
            except ValueError: return err("y => " & tmp[2])
    let w = try:   parseFloat(tmp[3])
            except ValueError: return err("w => " & tmp[3])
    let h = try:   parseFloat(tmp[4])
            except ValueError: return err("h => " & tmp[4])

    info("rules:extract: new rule " & name & "=" & $x & $y & $w & $h)
    result = @[Rule(
        page: -1,
        name: name,
        ops: @[
            OpBase(
            OpExt(kind: pp_rules.operation_kind.ppk_clip,
                  x: x, y: y, w: w, h: h)
            )
        ]
    )]


proc parse_op(tbl: SectionTable, key, val: string): seq[Rule] =
    ##[ parses 1 rule from a key and val pair.
    ]##
    debug("rules:extract: parse " & key)
    case key.strip().toLower():
    of "extract":
        return parse_extract_as_seq(val)
    of "parse":
        return pp_parse_parse.parse_as_seq(val)
    of "output_csv":
        return pp_parse_output.parse_as_seq(val)
    else:
        error("rules:ignored the invalid key: ", $key, " and its value", $val)


proc parse_rules*(tbl: SectionTable): seq[Rule] =
    ##[
        - parse the global section.
    ]##
    debug("rules:parse: " & $tbl)
    for (key, val) in tbl[""]:
        for rule in parse_op(tbl, key, val):
            debug("rules:parse: add new rule: " & $rule)
            result.add(rule)


proc load*(filename: string): seq[Rule] =
    let path = Path(filename).expandTilde()
    if not os.fileExists(path.string):
        error("rules:load: rules file does not exist: " & path.string)
        return @[]

    let tbl = load_ini(path)
    if len(tbl) < 1:
        error("rules:load: can't load ini contents")
        return @[]
    debug("rules:parse: " & $tbl)
    return parse_rules(tbl)

