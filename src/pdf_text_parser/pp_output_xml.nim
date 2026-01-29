##[ pp_output_xml.nim

License: MIT, see LICENSE
]##
import pp_extracted
import pp_format
import pp_rules


proc output*(op: OpBase, src: openarray[pp_extracted.Block]): string =
    ##[ outputs the blocks data as CSV.
    ]##
    let op = OpOutputXml(op)
    let sfx = if op.f_space: "\n" else: ""
    let pfx = if op.f_space: "  " else: ""

    var ret = "<" & op.name & ">" & sfx
    for (name, tag, fmt) in op.outs:
        let blk = pp_extracted.find(src, name)
        let txt = if len(blk.name) < 1: ""
                  else:                 blk.text
        let tx2 = pp_format.format(fmt, txt)
        ret &= pfx & "<" & tag & ">" & tx2 &
                    "</" & tag & ">" & sfx
    ret &= "</" & op.name & ">" & sfx
    return ret

