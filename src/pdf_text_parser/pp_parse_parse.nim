##[ pp_parse.nim

License: MIT, see LICENSE
]##
import pp_rules


proc parse_as_seq*(val: string): seq[Rule] =
    ##[ parses the `val` as `parse` rule in a opt-val pair.
    ]##
    let tmp = pp_rules.split_to_cells(val)
    if len(tmp) < 4:
        return @[]

    var ret = OpParse(kind: pp_rules.operation_kind.ppk_parse,
                      name: tmp[0],
                      name_src: tmp[1],
                      fmt_parse: tmp[2],
                      fmt_store: tmp[3])
    return @[pp_rules.Rule(page: -1, name: "", ops: @[OpBase(ret)])]

