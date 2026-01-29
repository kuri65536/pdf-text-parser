##[ app_format.nim

License: MIT, see LICENSE
]##
import pp_extracted
import pp_output_csv
import pp_output_xml
import pp_rules


proc format_op(fp: File, op: pp_rules.OpBase,
               src: openarray[pp_extracted.Block]): void =
    ##[ runs the operation for input blocks.
    ]##
    if op of pp_rules.OpOutputCsv:
        let tmp = pp_output_csv.output(op, src)
        fp.write(tmp)
    elif op of pp_rules.OpOutputXml:
        let tmp = pp_output_xml.output(op, src)
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

