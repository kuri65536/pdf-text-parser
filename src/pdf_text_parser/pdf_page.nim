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


proc pdf_page_size*(page: PdfPage): tuple[w, h: float] =
    ##[ returns the size of PDF page.
    ]##
    let p_page = page.page
    var (w, h) = (0.0, 0.0)
    {.emit: """ {double _w, _h;
                 poppler_page_get_size(`p_page`, &_w, &_h);
                 `w` = _w; `h` = _h;
                 }
            """.}
    return (w, h)


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

