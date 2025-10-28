##[ pdf_page.nim

this is wrapper functions to treat the `PopplerPage` objects.

License: MIT, see LICENSE
]##
{.emit: "#include <poppler/glib/poppler-document.h>".}

import pdf_common

type
  PdfPage* = ref object of RootObj
    doc*: PdfDoc
    page*: pointer


proc pdf_pages*(pdf: PdfDoc): seq[int] =
    ##[ gets a sequence of the page numbers.
    ]##
    let p_doc = pdf.doc
    assert not isNil(p_doc), pdf.filename.string
    var n: int
    {.emit: """ `n` = poppler_document_get_n_pages(`p_doc`);
            """.}
    result = @[]
    for i in 0 .. n - 1:
        result.add(i)


proc pdf_page*(pdf: PdfDoc, n: int): PdfPage =
    ##[ opens the `page` object from the page number.
    ]##
    let p_doc = pdf.doc
    var page: pointer
    {.emit: """ `page` = poppler_document_get_page(`p_doc`, `n`);
            """.}
    if isNil(page):
        return nil

    result = PdfPage(doc: pdf, page: page)

