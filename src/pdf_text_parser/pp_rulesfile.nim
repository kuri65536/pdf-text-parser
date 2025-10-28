##[ pp_rulesfile.nim

License: MIT, see LICENSE
]##
import os
import std/paths
import strutils
import tables

import pp_rules
import pp_inifile


proc parse_extract_as_seq(val: string): seq[Rule] =
    ##[ parses the `val` as `extract` rule in a opt-val pair.
    ]##
    let tmp = block:
        var tmp2: seq[string]
        for i in val.split(","): tmp2.add(i.strip())
        tmp2
    if len(tmp) < 1:
        echo("rules:extract: ignored the invalid line: " & val); return @[]
    let name = tmp[0]
    if len(tmp) < 5:
        echo("rules:extract: ignored the invalid rect: " & val); return @[]
    proc err(msg: string): seq[Rule] =
        echo("rules:extract: error with " & msg); return @[]
    let x = try:   parseFloat(tmp[1])
            except ValueError: return err("x => " & tmp[1])
    let y = try:   parseFloat(tmp[2])
            except ValueError: return err("y => " & tmp[2])
    let w = try:   parseFloat(tmp[3])
            except ValueError: return err("w => " & tmp[3])
    let h = try:   parseFloat(tmp[4])
            except ValueError: return err("h => " & tmp[4])

    result = @[Rule(
        page: -1,
        name: name,
        ops: @[
            OpExt(kind: pp_rules.operation_kind.ppk_clip,
                  x: x, y: y, w: w, h: h)
        ]
    )]


proc parse_op(tbl: SectionTable, key, val: string): seq[Rule] =
    ##[ parses 1 rule from a key and val pair.
    ]##
    case key.strip().toLower():
    of "extract":
        return parse_extract_as_seq(val)
    else:
        discard


proc parse_rules*(tbl: SectionTable): seq[Rule] =
    ##[
        - parse the global section.
    ]##
    for (key, val) in tbl[""]:
        for rule in parse_op(tbl, key, val):
            result.add(rule)


proc load*(filename: string): seq[Rule] =
    let path = Path(filename).expandTilde()
    if not os.fileExists(path.string):
        return @[]

    let tbl = load_ini(path)
    if len(tbl) < 1:
        return @[]
    return parse_rules(tbl)

