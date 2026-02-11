##[ pp_output_json.nim

License: MIT, see LICENSE
]##
import json

import pp_extracted
import pp_format
import pp_rules


proc output_header*(op: OpBase): string =
    ##[ outputs the header data in the JSON outputs.
    ]##
    return "["


proc output_inter*(op: OpBase): string =
    ##[ outputs the footer data in the JSON outputs.

        ```
        [{
        }, {
        ...
        }]```
    ]##
    let op = OpOutputJson(op)
    if op.f_space:
        return ", "
    return ","


proc output_footer*(op: OpBase): string =
    ##[ outputs the footer data in the JSON outputs.
    ]##
    return "]"


proc output*(op: OpBase, src: openarray[pp_extracted.Block]): string =
    ##[ outputs the blocks data with the JSON format.
    ]##
    let op = OpOutputJson(op)
    let sfx = if op.f_space: "\n" else: ""
    let pfx = if op.f_space: "  " else: ""
    let sep = if op.f_space: " " else: ""

    var ret = "{"
    for (name, attr, fmt) in op.outs:
        if len(ret) > 1:
            ret &= "," & sfx
        else:
            ret &= sfx
        let blk = pp_extracted.find(src, name)
        let txt = if len(blk.name) < 1: ""
                  else:                 blk.text
        let tx2 = pp_format.format(fmt, txt)
        ret &= pfx & json.escapeJson(attr) & ":" & sep &
                     json.escapeJson(tx2)
    ret &= sfx & "}"
    return ret

