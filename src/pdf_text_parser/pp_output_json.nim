##[ pp_output_json.nim

License: MIT, see LICENSE
]##
import json
import std/streams

import pp_output
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


proc output_single(op: pp_rules.OpOutputJson,
                   src: openarray[pp_extracted.Block]): string =
    ##[ outputs the blocks data with the JSON format.
    ]##
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


proc output*(strm: Stream, op: pp_rules.OpBase,
             src: openarray[pp_extracted.Block],
             opts: set[output_options]): void =
    ##[ outputs the blocks data with the JSON format with delimiters
    ]##
    let op = pp_rules.OpOutputJson(op)
    if opts.contains(output_head):
        let s = output_header(op)
        strm.write(s)
    elif opts.contains(output_inter) or opts.contains(output_tail):
        let s = output_inter(op)
        strm.write(s)
    let tmp = output_single(op, src)
    strm.write(tmp)
    if opts.contains(output_tail):
        let s = output_footer(op)
        strm.write(s)

