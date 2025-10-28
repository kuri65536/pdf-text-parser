##[ pdf_doc.nim

License: MIT, see LICENSE
]##
{.passC: gorge("pkg-config --cflags poppler-glib").}
{.passL: gorge("pkg-config --libs poppler-glib").}
{.emit: "#include <poppler/glib/poppler.h>".}

import std/paths

import pdf_common

export PdfDoc


proc open_pdf(a, b: cstring): pointer =
    var
        msg: cstring
        dom, code: int
    {.emit: """ GError* err = NULL;
                `result` = poppler_document_new_from_file(`a`, `b`, &err);
                if (`result` == NULL) {
                    `dom` = err->domain;
                    `msg` = err->message;
                    `code` = err->code;
                }
            """.}
    if isNil(result):
        echo("pdf_open:error: " & $dom & "-" & $code & " " & $msg)


proc pdf_open*(filename: Path): PdfDoc =
    let uri = "file://" & filename.absolutePath().string
    let doc = open_pdf(uri.cstring, nil)
    if isNil(doc):
        echo("pdf_open:cannot open file"); return nil

    result = PdfDoc(doc: doc,
                    filename: filename.string,
                    )


proc pdf_close*(pdf: PdfDoc): void =
    ## .. note:: todo ... implement
    discard


