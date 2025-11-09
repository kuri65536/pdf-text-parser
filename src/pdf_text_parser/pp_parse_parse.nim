##[ pp_parse.nim

License: MIT, see LICENSE
]##
import logging
import strutils

import pp_rules


proc parse_type*(val: string): pp_rules.parse_kind =
    ##[ parse an input string to `parse_kind`
    ]##
    case val.toLower().strip():
    of "date-time": return pp_rules.parse_kind.prk_datetime
    of "string":    return pp_rules.parse_kind.prk_string
    else:           discard
    error("rule:parse:invalid data-type => '" & val & "'")
    return pp_rules.parse_kind.prk_string


proc parse_as_seq*(val: string): seq[Rule] =
    ##[ parses the `val` as `parse` rule in a opt-val pair.
    ]##
    let tmp = pp_rules.split_to_cells(val)
    if len(tmp) < 4:
        return @[]

    var ret = OpParse(kind: pp_rules.operation_kind.ppk_parse,
                      name: tmp[0],
                      name_src: tmp[1],
                      typ: parse_type(tmp[2]),
                      fmt_parse: tmp[3],
                      fmt_store: tmp[4])
    return @[pp_rules.Rule(page: -1, name: "", ops: @[OpBase(ret)])]

