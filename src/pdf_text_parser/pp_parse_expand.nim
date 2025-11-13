##[ pp_parse_expand.nim

License: MIT, see LICENSE
]##
import pp_rules


const
  identifier* = "expand"


proc parse_op*(val: string): OpExpand =
    ##[ parses the `val` as `expand` rule in a opt-val pair.
    ]##
    let tmp = pp_rules.split_to_cells(val)

    return OpExpand(kind: pp_rules.operation_kind.ppk_expand,
                    section: tmp[0])

