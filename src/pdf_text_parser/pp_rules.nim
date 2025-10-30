##[ pp_rules.nim

License: MIT, see LICENSE
]##
import strutils


type
  operation_kind* = enum
    ppk_invalid,
    ppk_clip,
    ppk_parse,

  OpBase* = ref OpBaseObj
  OpBaseObj* = object of RootObj
    kind*: operation_kind

  OpExt* = ref OpExtObj
  OpExtObj* = object of OpBase
    ## the extract operation
    x*, y*, w*, h*: float

  OpParse* = ref OpParseObj
  OpParseObj* = object of pp_rules.OpBase
    name*: string
    name_src*: string
    fmt_parse*: string
    fmt_store*: string

  Rule* = object of RootObj
    page*: int
    name*: string
    ops*: seq[OpBase]


proc split_to_cells*(val: string): seq[string] =
    ##[ splits the string to cells, such as:

        `a, b, c, d` to "a", "b", "c", "d"
    ]##
    result = @[]
    for i in val.split(","):
        result.add(i.strip())

