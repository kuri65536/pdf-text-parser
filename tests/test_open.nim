##[test_open.nim

License: MIT, see LICENSE
]##
import std/paths

import ../src/pdf_text_parser/pdf_doc

var pdf = pdf_doc.pdf_open(Path("test.pdf"))
assert not isNil(pdf)

pdf_doc.pdf_close(pdf)

