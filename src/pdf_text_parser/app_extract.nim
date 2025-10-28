##[ app_extract.nim

License: MIT, see LICENSE
]##
import std/paths

import pdf_doc

import pp_rules


proc extract_blocks*(rules: seq[pp_rules.Rule], fname: Path
                     ): seq[pp_extracted.Block] =
    ##[ extracts the element from a PDF file.
    ]##
    var pdf = pdf_doc.pdf_open(fname)
    if isNil(pdf):
        return @[]
    defer: pdf_doc.pdf_close(pdf)

    result = @[]
