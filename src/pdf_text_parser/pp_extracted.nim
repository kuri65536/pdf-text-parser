##[ pp_extracted.nim

License: MIT, see LICENSE
]##


type
  Block* = ref BlockObj
  BlockObj* = object of RootObj
    name*: string
    text*: string

  BlockPairs* = ref BlockPairsObj
  BlockPairsObj* = object of Block
    pairs*: seq[tuple[key, value: string]]


proc find*(src: openarray[pp_extracted.Block], id: string): pp_extracted.Block =
    ##[ find the `Block` for the id.
    ]##
    for i in src:
        if i.name == id:
            return i
    return pp_extracted.Block()


proc find_with_key*(src: openarray[pp_extracted.Block], id, key: string
                    ): pp_extracted.Block =
    ##[ find the `BlockPair` and its value for `key`
    ]##
    for blk in src:
        if blk.name != id:
            continue
        if not(blk of BlockPairs):
            continue
        let tmp = BlockPairs(blk)
        for (k, v) in tmp.pairs:
            if k != key:
                continue
            return pp_extracted.Block(
                name: "---", text: v,
            )
        return nil
    return nil

