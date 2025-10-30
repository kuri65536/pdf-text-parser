
src:=src/pdf_text_parser.nim \
     src/pdf_text_parser/app_extract.nim \
     src/pdf_text_parser/app_parse.nim \
     src/pdf_text_parser/app_parse_datetime.nim \
     src/pdf_text_parser/options.nim \
     src/pdf_text_parser/options_macro.nim \
     src/pdf_text_parser/pdf_common.nim \
     src/pdf_text_parser/pdf_doc.nim \
     src/pdf_text_parser/pdf_get_text.nim \
     src/pdf_text_parser/pdf_page.nim \
     src/pdf_text_parser/pp_format.nim \
     src/pdf_text_parser/pp_inifile.nim \
     src/pdf_text_parser/pp_parse_output.nim \
     src/pdf_text_parser/pp_parse_parse.nim \
     src/pdf_text_parser/pp_rules.nim \
     src/pdf_text_parser/pp_rulesfile.nim \

exe:=pdf-text-parser

all:     $(exe)
	./$(exe) -r tests/rule1.ini -o test1.pdf tests/test1.pdf

build:   $(exe)

$(exe):  export PATH:=$(PATH):/usr/local/bin
$(exe):  $(src)
	nimble build
	mv -f $(subst -,_,$(exe)) $(exe)


.PHONY: all build
