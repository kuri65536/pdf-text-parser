##[ app_extract_pairs.nim

License: MIT, see LICENSE
]##
import logging
import math
import osproc
import parsexml
import streams
import strutils
import tables

import pdf_get_text
import pdf_page

import pp_extracted
import pp_rules


type
    area_struct = tuple[x1, y1, x2, y2: float, data: string]


proc get_word*(x: var XmlParser): area_struct =
    ##[ parse XML: `<word attr... >data</word>`

        not work with nested elements.
    ]##
    proc parse_num(s: string): float =
        try:               strutils.parseFloat(s)
        except ValueError: NaN

    debug("extract:pairs:get_word: enter")
    var (x1, x2, y1, y2) = (NaN, NaN, NaN, NaN)
    var data = ""
    while true:
        parsexml.next(x)
        case x.kind
        of xmlAttribute:
            let (k, v) = (x.attrKey, x.attrValue)
            if   k == "xMin": x1 = parse_num(v)
            elif k == "yMin": y1 = parse_num(v)
            elif k == "xMax": x2 = parse_num(v)
            elif k == "yMax": y2 = parse_num(v)
        of xmlCharData:
            data &= x.charData
        of xmlWhitespace:
            data &= x.charData
        of xmlCData:
            data &= x.charData
        of xmlSpecial:
            data &= x.charData
        of xmlElementEnd:
            if x.elementName == "word":
                break
        of xmlEof:
            return (NaN, NaN, NaN, NaN, "")
        else:
            discard
    debug("extract:pairs:get_word: leave " & data)
    return (x1, y1, x2, y2, data)
            


proc get_areas*(xml: Stream): seq[area_struct] =
    result = @[]

    var x: XmlParser
    parsexml.open(x, xml, "tmp.xml")
    defer: parsexml.close(x)
    while true:
        parsexml.next(x)
        case x.kind
        of xmlElementOpen:
            if x.elementName != "word": continue
            let tmp = get_word(x)
            if math.isNaN(tmp.x1):      continue
            result.add(tmp)
        of xmlEof: break
        else:      discard


proc split_to_rows*(areas: seq[area_struct], bd: float
                    ): Table[int, seq[area_struct]] =
    ##[
    ]##
    proc y2key(s: float): int =
        int(s * 10.0 + 0.5)
    for i in areas:
        var f_ins = false
        var row_pos: seq[int]
        for j in result.keys():
            row_pos.add(j)
        for j in row_pos:
            let d = abs(y2key(i.y2) - j)
            if d < y2key(bd):
                result[j] = result[j] & @[i]
                f_ins = true
                break
        if f_ins:
            continue
        let j0 = y2key(i.y2)
        result[j0] = @[i]


proc match_pairs*(row: var seq[area_struct], pair_area: PairArea
                  ): seq[tuple[k, v: area_struct]] =
    ##[
    ]##
    proc contains(x, w: float, b: area_struct): bool =
        # <-b->    <--a--..
        if b.x2 < x:     return false
        # ..-a->   <-b->
        if b.x1 > x + w: return false
        return true

    var ak, av: tuple[n: int, a: area_struct]
    (ak.n, av.n) = (-1, -1)
    for n, i in row:
        if ak.n < 0:
            if contains(pair_area.x1, pair_area.w1, i):
                ak = (n, i); continue 
        if av.n < 0:
            if contains(pair_area.x2, pair_area.w2, i):
                av = (n, i); continue
    if ak.n >= 0 and av.n >= 0:
        debug("extract:pairs:register " & ak.a.data & "-" & av.a.data)
        result.add((ak.a, av.a))
        if ak.n > av.n:
            row.delete(ak.n)
            row.delete(av.n)
        else:
            row.delete(av.n)
            row.delete(ak.n)
    debug("extract:pairs:register as a pair: " & $result)
    return result


proc compose_pairs*(fname: string, op: pp_rules.OpPairs
                    ): seq[tuple[k, v: area_struct]] =
    ##[
    ]##
    let cmd = "pdftotext -bbox '" & fname & "' /dev/stdout"
    let (stdo, stat) = osproc.execCmdEx(cmd)
    if stat != 0:
        error("extract:pairs: can't get structure(" & $stat & ") with " & cmd)
        return @[]
    let strm = newStringStream(stdo)
    defer: strm.close()
    let areas = get_areas(strm)
    var tbl = split_to_rows(areas, op.base_diff)
    debug("extract:pairs:compose: rows " & $tbl)
    for j in tbl.keys():
        var areas_in1row = tbl[j]
        for i in op.areas:
            let pairs = match_pairs(areas_in1row, i)
            if len(pairs) > 0:
                warn("extract:pairs:register as a pair: " & $pairs)
                result.add(pairs)
        if len(tbl[j]) != len(areas_in1row):
            tbl[j] = areas_in1row
        else:
            debug("not match in row: " & $j)


proc extract_pair_str*(page: PdfPage, area: area_struct): string =
    result = pdf_get_text.pdf_get_text(page, area.x1, area.y1, area.x2, area.y2)


proc extract_pairs*(page: PdfPage, op: pp_rules.OpPairs): pp_extracted.Block =
    ##[ extract the table text to the sequence of tuple `key-value`
    ]##
    debug("extract:pairs: " & op.name & " => " & page.doc.filename)

    var ret: seq[tuple[key, value: string]]
    for (area_key, area_val) in compose_pairs(page.doc.filename, op):
        let (k, v) =
            when true:
                (area_key.data, area_val.data)
            else:
                (extract_pair_str(page, area_key),
                 extract_pair_str(page, area_val))
        if len(v) < 1:
            error("extract:pairs: failed to extract value: " & $area_val)
        if len(k) < 1:
            error("extract:pairs: failed to extract key: " & $area_key)
            continue
        debug("extract:pairs:register as the pairs key:" & area_key.data)
        ret.add((k, v))

    warn("extract:pairs:extracted " & op.name & " => " & $len(ret))
    return BlockPairs(name: op.name, text: page.doc.filename,
                      pairs: ret)

