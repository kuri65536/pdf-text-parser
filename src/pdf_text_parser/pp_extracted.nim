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
    ##[
    ]##
    for i in src:
        if i.name == id:
            return i
    return pp_extracted.Block()

