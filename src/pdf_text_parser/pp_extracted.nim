##[ pp_extracted.nim

License: MIT, see LICENSE
]##


type
  Block* = object of RootObj
    name*: string
    text*: string


proc find*(src: openarray[pp_extracted.Block], id: string): pp_extracted.Block =
    ##[
    ]##
    for i in src:
        if i.name == id:
            return i
    return pp_extracted.Block()

