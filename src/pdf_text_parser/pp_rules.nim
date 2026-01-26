##[ pp_rules.nim

License: MIT, see LICENSE
]##
import strutils


type
  parse_kind* = enum
    prk_string,
    prk_datetime,

  calc_kind* = enum
    pck_add,
    pck_sub,
    pck_mul,
    pck_concat,
    pck_ternary,

  OpBase* = ref OpBaseObj
  OpBaseObj* = object of RootObj
    discard

  OpCalc* = ref OpCalcObj
  OpCalcObj* = object of OpBase
    name_dest*: string
    calc*: calc_kind
    exprs*: seq[OpBase]

  OpExpand* = ref OpExpandObj
  OpExpandObj* = object of OpBase
    ## the call operation
    section*: string

  OpExtract* = ref OpExtractObj
  OpExtractObj* = object of OpBase
    ## the extract operation
    x*, y*, w*, h*: float
    name*: string

  OpGet* = ref OpGetObj
  OpGetObj* = object of pp_rules.OpBase
    name_dest*: string
    name_src*: string
    key*: string

  OpParse* = ref OpParseObj
  OpParseObj* = object of pp_rules.OpBase
    name*: string
    name_src*: string
    typ*: parse_kind
    fmt_parse*: string
    fmt_store*: string

  PairArea* = tuple[x1, w1, x2, w2: float]

  OpPairs* = ref OpPairsObj
  OpPairsObj* = object of pp_rules.OpBase
    name*: string
    areas*: seq[PairArea]
    base_diff*: float

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

