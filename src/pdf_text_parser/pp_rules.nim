##[ pp_rules.nim

License: MIT, see LICENSE
]##


type
  operation_kind* = enum
    ppk_invalid,
    ppk_clip,

  OpExt* = object of RootObj
    ## the extract operation
    kind*: operation_kind
    x*, y*, w*, h*: float

  Rule* = object of RootObj
    page*: int
    name*: string
    ops*: seq[OpExt]

