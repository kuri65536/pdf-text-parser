##[ pp_rules.nim

License: MIT, see LICENSE
]##
import strutils


type
  operation_kind* = enum
    ppk_invalid,
    ppk_clip,
    ppk_parse,
    ppk_csv,
    ppk_expand,

  parse_kind* = enum
    prk_string,
    prk_datetime,

  OpBase* = ref OpBaseObj
  OpBaseObj* = object of RootObj
    kind*: operation_kind

  OpExpand* = ref OpExpandObj
  OpExpandObj* = object of OpBase
    ## the call operation
    section*: string

  OpExt* = ref OpExtObj
  OpExtObj* = object of OpBase
    ## the extract operation
    x*, y*, w*, h*: float
    name*: string

  OpParse* = ref OpParseObj
  OpParseObj* = object of pp_rules.OpBase
    name*: string
    name_src*: string
    typ*: parse_kind
    fmt_parse*: string
    fmt_store*: string

  TupleCsv = tuple[name, fmt: string]

  OpFormatCsv* = ref OpFormatCsvObj
  OpFormatCsvObj* = object of pp_rules.OpBase
    outs*: seq[TupleCsv]

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

