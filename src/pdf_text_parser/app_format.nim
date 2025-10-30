##[ app_format.nim

License: MIT, see LICENSE
]##
import app_format_csv
import pp_extracted
import pp_rules


proc format_op(fp: File, op: pp_rules.OpBase,
               src: openarray[pp_extracted.Block]): void =
    ##[ runs the operation for input blocks.
    ]##
    case op.kind:
    of pp_rules.operation_kind.ppk_csv:
        let tmp = app_format_csv.output(op, src)
        fp.write(tmp)
    else:
        discard


proc format*(rules: openarray[pp_rules.Rule],
             src: openarray[pp_extracted.Block]): void =
    ##[ outputs the extracted and parsed blocks with specified rules.
    ]##
    let fp = system.stdout
    for rule in rules:
        for op in rule.ops:
            format_op(fp, op, src)

