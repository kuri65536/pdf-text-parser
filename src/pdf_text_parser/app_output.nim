##[ app_output.nim

License: MIT, see LICENSE
]##
import streams

import pp_extracted
import pp_output
import pp_output_csv
import pp_output_json
import pp_output_xml
import pp_rules

export output_options


proc output_op(fp: Stream, op: pp_rules.OpBase,
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
        pp_output_json.output(fp, op, src, opts)
    else:
        discard


proc output*(fp: Stream, rules: openarray[pp_rules.Rule],
             src: openarray[pp_extracted.Block],
             opts: set[output_options]): void =
    ##[ outputs the extracted and parsed blocks with specified rules.
    ]##
    for rule in rules:
        for op in rule.ops:
            output_op(fp, op, src, opts)

