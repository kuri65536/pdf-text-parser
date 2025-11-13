##[ app_extract.nim

License: MIT, see LICENSE
]##
import logging
import std/paths

import pdf_doc
import pdf_get_text
import pdf_page

import pp_extracted
import pp_rules


proc match_rules_for_page*(rules: seq[pp_rules.Rule], page: int
                           ): seq[pp_rules.Rule] =
    ##[ filters rules for the specified page.
    ]##
    result = @[]
    for rule in rules:
        if rule.page == -1:  # match all pages
            result.add(rule); continue
        if rule.page == page:
            result.add(rule); continue


proc extract_text*(page: PdfPage, x, y, w, h: float): string =
    ##[
    ]##
    return pdf_get_text.pdf_get_text(page, x, y, w, h)


proc extract_block*(page: PdfPage, op: pp_rules.OpBase): pp_extracted.Block =
    ##[
    ]##
    let fallback = Block(name: "")
    if not (op of pp_rules.OpExt):
        return fallback

    let opc = OpExt(op)
    let tmp = extract_text(page, opc.x, opc.y, opc.w, opc.h)
    debug("extract:clip: " & opc.name & " => " & tmp)
    return Block(name: opc.name, text: tmp)


proc extract_blocks_in_a_rule*(page: PdfPage, rule: pp_rules.Rule
                               ): seq[pp_extracted.Block] =
    ##[
    ]##
    for op in rule.ops:
        let blk = extract_block(page, op)
        if len(blk.name) < 1:
            continue
        result.add(blk)


proc extract_blocks*(rules: seq[pp_rules.Rule], fname: Path
                     ): seq[pp_extracted.Block] =
    ##[ extracts the element from a PDF file.
    ]##
    var pdf = pdf_doc.pdf_open(fname)
    if isNil(pdf):
        return @[]
    debug("extract:opened PDF file ... " & fname.string)
    defer: pdf_doc.pdf_close(pdf)

    result = @[]
    for n in pdf_page.pdf_pages(pdf):
        let rules_page = match_rules_for_page(rules, n)
        if len(rules_page) < 1:
            continue
        let page = pdf_page.pdf_page(pdf, n)
        let (w, h) = pdf_page_size(page)
        debug("extract:load page ... " & $n & " => (" & $w & "," & $h & ")")
        for rule in rules_page:
            let blks = extract_blocks_in_a_rule(page, rule)
            if len(blks) < 1: continue
            result.add(blks)

