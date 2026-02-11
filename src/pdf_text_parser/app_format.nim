##[ app_format.nim

License: MIT, see LICENSE
]##
import pp_extracted
import pp_output_csv
import pp_output_json
import pp_output_xml
import pp_rules


proc format_op(fp: File, op: pp_rules.OpBase,
               src: openarray[pp_extracted.Block],
               f_head, f_tail: bool): void =
    ##[ runs the operation for input blocks.
    ]##
    if op of pp_rules.OpOutputCsv:
        let tmp = pp_output_csv.output(op, src)
        fp.write(tmp)
    elif op of pp_rules.OpOutputXml:
        let tmp = pp_output_xml.output(op, src)
        fp.write(tmp)
    elif op of pp_rules.OpOutputJson:
        if f_head:
            let s = pp_output_json.output_header(op)
            fp.write(s)
        else:
            let s = pp_output_json.output_inter(op)
            fp.write(s)
        let tmp = pp_output_json.output(op, src)
        fp.write(tmp)
        if f_tail and not f_head:
            let s = pp_output_json.output_footer(op)
            fp.write(s)
    else:
        discard


proc format*(rules: openarray[pp_rules.Rule],
             src: openarray[pp_extracted.Block],
             f_head, f_tail: bool): void =
    ##[ outputs the extracted and parsed blocks with specified rules.
    ]##
    let fp = system.stdout
    for rule in rules:
        for op in rule.ops:
            format_op(fp, op, src, f_head, f_tail)

