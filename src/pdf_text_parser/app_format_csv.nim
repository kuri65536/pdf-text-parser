##[ app_format_csv.nim

License: MIT, see LICENSE
]##
import strutils

import pp_extracted
import pp_format
import pp_rules


proc output*(op: OpBase, src: openarray[pp_extracted.Block]): string =
    ##[ outputs the blocks data as CSV.
    ]##
    var ret: seq[string]
    let opcsv = OpFormatCsv(op)
    for (name, fmt) in opcsv.outs:
        let blk = pp_extracted.find(src, name)
        let txt = if len(blk.name) < 1: ""
                  else:                 blk.text
        let tx2 = pp_format.format(fmt, txt)
        ret.add(tx2)
    return strutils.join(ret, ",") & "\n"
    

