##[ pdf_common.nim

License: MIT, see LICENSE
]##


type
  PdfDoc* = ref object of RootObj
    doc*: pointer
    filename*: string

