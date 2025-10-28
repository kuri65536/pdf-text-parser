##[ pdf_get_text.nim

License: MIT, see LICENSE
]##
{.passC: gorge("pkg-config --cflags poppler-glib").}
{.passL: gorge("pkg-config --libs poppler-glib").}
{.emit: "#include <poppler/glib/poppler.h>".}

import pdf_page


proc pdf_get_text0*(page: PdfPage, x, y, w, h: float): string =
    ##[ gets the text by `poppler_page_get_text_for_area` .
    ]##
    var tmp: cstring
    let p_page = page.page
    let (x2, y2) = (x + w, y + h)
    {.emit: """ {
                PopplerRectangle rect = {.x1 = `x`, .y1 = `y`,
                                         .x2 = `x2`, .y2 = `y2`};
                `tmp` = poppler_page_get_text_for_area(`p_page`, &rect);
                }
            """.}
    if isNil(tmp):
        return ""
    return $tmp


proc pdf_get_text*(page: PdfPage, x1, y1, x2, y2: float): string =
    ##[ gets the text by `poppler_page_get_selected_text`
        with the type of `POPPLER_SELECTION_GLYPH` .
    ]##
    var tmp: cstring
    let p_page = page.page
    {.emit: """ {
                PopplerRectangle rect = {.x1 = `x1`, .y1 = `y2`,
                                         .x2 = `x2`, .y2 = `y2`};
                `tmp` = poppler_page_get_selected_text(
                        `p_page`, POPPLER_SELECTION_GLYPH, &rect);
                }
            """.}
    if isNil(tmp):
        return ""
    return $tmp

