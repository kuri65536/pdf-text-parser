
src:=src/pdf_text_parser.nim \
     src/pdf_text_parser/app_extract.nim \
     src/pdf_text_parser/app_extract_pairs.nim \
     src/pdf_text_parser/app_format.nim \
     src/pdf_text_parser/app_parse.nim \
     src/pdf_text_parser/app_parse_calc.nim \
     src/pdf_text_parser/app_parse_datetime.nim \
     src/pdf_text_parser/app_parse_get.nim \
     src/pdf_text_parser/app_parse_string.nim \
     src/pdf_text_parser/options.nim \
     src/pdf_text_parser/options_macro.nim \
     src/pdf_text_parser/pdf_common.nim \
     src/pdf_text_parser/pdf_doc.nim \
     src/pdf_text_parser/pdf_get_text.nim \
     src/pdf_text_parser/pdf_page.nim \
     src/pdf_text_parser/pp_eval_calc.nim \
     src/pdf_text_parser/pp_eval_calc_concat.nim \
     src/pdf_text_parser/pp_eval_calc_ternary.nim \
     src/pdf_text_parser/pp_extracted.nim \
     src/pdf_text_parser/pp_format.nim \
     src/pdf_text_parser/pp_inifile.nim \
     src/pdf_text_parser/pp_output_csv.nim \
     src/pdf_text_parser/pp_output_json.nim \
     src/pdf_text_parser/pp_output_xml.nim \
     src/pdf_text_parser/pp_parse_calc.nim \
     src/pdf_text_parser/pp_parse_expand.nim \
     src/pdf_text_parser/pp_parse_output.nim \
     src/pdf_text_parser/pp_parse_output_json.nim \
     src/pdf_text_parser/pp_parse_output_xml.nim \
     src/pdf_text_parser/pp_parse_pairs.nim \
     src/pdf_text_parser/pp_parse_parse.nim \
     src/pdf_text_parser/pp_rules.nim \
     src/pdf_text_parser/pp_rulesfile.nim \

exe:=pdf-text-parser
prefix:=/usr/local

all:     $(exe)

run:     $(exe)
	#/$(exe) -r tests/rule1.ini -o test1.pdf tests/test1.pdf
	#/$(exe) -r tests/rule3.ini:test -o test1.pdf tests/test1.pdf
	#/$(exe) -r tests/rule4.ini -o test1.pdf tests/test1.pdf -V 4
	./$(exe) $(args)

debug:   $(exe)
	nim-gdb --args $(exe) $(args)

build:   $(exe)

test:    export PATH:=$(PATH):/usr/local/bin
test:    pat:=$(if $(args),$(args),'tests/*.nim')
test:    $(exe)
	testament --print pattern $(pat)

$(exe):  export PATH:=$(PATH):/usr/local/bin
$(exe):  $(src)
	nimble build
	mv -f $(subst -,_,$(exe)) $(exe)

install: $(exe)
	install -D $< $(DESTDIR)$(prefix)/bin/$(notdir $<)


deb:   pkg:=pdf-text-parser-0.1
deb:   files:=src Makefile LICENSE pdf_text_parser.nimble
deb:   $(exe)
	rm -rf   build/$(pkg)
	rm -f    build/$(pkg).tar.gz
	mkdir -p build/$(pkg)/debian
	cp -r build/debian-rules/* build/$(pkg)/debian
	tar czvf build/$(pkg).tar.gz --transform s,^src,$(pkg)/src, $(files)
	cp -r $(files)  build/$(pkg)
	cd       build/$(pkg); debmake
	cd       build/$(pkg); EDITOR=/bin/true dpkg-source --commit . 1
	cd       build/$(pkg); debuild


zip:   pkg:=pdf-text-parser-0.1
zip:   pkg:=$(pkg).zip
zip:   docs:=README.md LICENSE
zip:
	rm -rf tmp $(pkg)
	mkdir tmp
	cp $(docs) $(exe) tmp
	(echo "[InternetShortcut]"; \
      echo "URL=$$(git remote get-url origin)") > tmp/web-site.url
	ldd tmp/$(exe) | grep ucrt64 | cut -d " " -f 1 | \
	     while read l; do cp /ucrt64/bin/$$l tmp; done
	cd tmp; zip -gur ../$(pkg) *
	rm -rf tmp


.PHONY: all build deb install
