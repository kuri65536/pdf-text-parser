##[ app_extract.nim

License: MIT, see LICENSE
]##
import std/paths

import pdf_doc
import pdf_get_text
import pdf_page

import pp_extracted
import pp_rules


proc extract_text*(page: PdfPage, x, y, w, h: float): string =
    ##[
    ]##
    return pdf_get_text.pdf_get_text(page, x, y, w, h)


proc extract_block*(page: PdfPage, rule: pp_rules.Rule): pp_extracted.Block =
    ##[
    ]##
    for op in rule.ops:
        case op.kind:
        of ppk_clip:
            let tmp = extract_text(page, op.x, op.y, op.w, op.h)
            return Block(name: rule.name, text: tmp)
        of ppk_invalid:
            discard
        #[else:
            discard]#
    return Block(name: "")  # returns as an invalid.


proc extract_blocks*(rules: seq[pp_rules.Rule], fname: Path
                     ): seq[pp_extracted.Block] =
    ##[ extracts the element from a PDF file.
    ]##
    var pdf = pdf_doc.pdf_open(fname)
    if isNil(pdf):
        return @[]
    defer: pdf_doc.pdf_close(pdf)

    result = @[]
    for n in pdf_page.pdf_pages(pdf):
        let page = pdf_page.pdf_page(pdf, n)
        for rule in rules_page:
            let blk = extract_block(page, rule)
            if len(blk.name) < 1: break
            result.add(blk)

