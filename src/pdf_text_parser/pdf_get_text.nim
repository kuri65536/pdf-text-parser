##[ pdf_get_text.nim

License: MIT, see LICENSE
]##
{.passC: gorge("pkg-config --cflags poppler-glib").}
{.passL: gorge("pkg-config --libs poppler-glib").}
{.emit: "#include <poppler/glib/poppler.h>".}

import pdf_page


proc pdf_get_text*(page: PdfPage, x, y, w, h: float): string =
    ## .. note:: todo ... implement
    var tmp: cstring
    let p_page = page.page
    {.emit: """ {
                PopplerRectangle rect = {.x1 = `x`, .y1 = `y`,
                                         .x2 = `x` + `w`, .y2 = `y` + `h`};
                `tmp` = poppler_page_get_text_for_area(`p_page`, &rect);
                }
            """.}
    if isNil(tmp):
        return ""
    return $tmp

