##[ app_format.nim

License: MIT, see LICENSE
]##
import streams

import pp_extracted
import pp_output_csv
import pp_output_json
import pp_output_xml
import pp_rules


type
  output_options* = enum
    output_head
    output_tail
    output_inter


proc format_op(fp: Stream, op: pp_rules.OpBase,
               src: openarray[pp_extracted.Block],
               opts: set[output_options]): void =
    ##[ runs the operation for input blocks.
    ]##
    if op of pp_rules.OpOutputCsv:
        let tmp = pp_output_csv.output(op, src)
        fp.write(tmp)
    elif op of pp_rules.OpOutputXml:
        let tmp = pp_output_xml.output(op, src)
        fp.write(tmp)
    elif op of pp_rules.OpOutputJson:
        if opts.contains(output_head):
            let s = pp_output_json.output_header(op)
            fp.write(s)
        elif opts.contains(output_inter):
            let s = pp_output_json.output_inter(op)
            fp.write(s)
        let tmp = pp_output_json.output(op, src)
        fp.write(tmp)
        if opts.contains(output_tail):
            let s = pp_output_json.output_footer(op)
            fp.write(s)
    else:
        discard


proc format*(fp: Stream, rules: openarray[pp_rules.Rule],
             src: openarray[pp_extracted.Block],
             opts: set[output_options]): void =
    ##[ outputs the extracted and parsed blocks with specified rules.
    ]##
    for rule in rules:
        for op in rule.ops:
            format_op(fp, op, src, opts)

