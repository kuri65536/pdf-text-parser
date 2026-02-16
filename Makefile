
src:=src/pdf_text_parser.nim \
     $(wildcard src/pdf_text_parser/*.nim) \

src_tests:=\
           $(wildcard tests/*.nim) \

exe:=pdf-text-parser
prefix:=/usr/local

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
test:    $(exe) $(src_tests)
	testament --print pattern $(pat)

$(exe):  export PATH:=$(PATH):/usr/local/bin
$(exe):  $(src)
	nimble
	mv -f $(subst -,_,$(exe)) $(exe)

csource:  $(src)
	nim c --os:linux --compileOnly --genScript --nimcache:$@ \
	    src/pdf_text_parser.nim

install: $(exe)
	install -D $< $(DESTDIR)$(prefix)/bin/$(notdir $<)


# b:   pkg:=pdf-text-parser-$(shell git tag -l | sort -V -r | head -n1 \
#                                 | sed s/v// | sed 's/.[0-9]\+$$//' )
deb:   pkg:=pdf-text-parser-$(shell sed -n 's/^version *= \"\(.*\)\"/\1/p' \
                              pdf_text_parser.nimble | sed 's/.[0-9]\+$$//')
deb:   files:=LICENSE pdf_text_parser.nimble \
              csource/*.c csource/compile_pdf_text_parser.sh
deb:   opts_debuild1:=$(if $(opts_debuild),$(opts_debuild),)
deb:   csource
	rm -rf   build/$(pkg)
	rm -f    build/$(pkg).tar.gz
	mkdir -p build/$(pkg)/debian
	cp -r build/debian-rules/* build/$(pkg)/debian
	tar czvf build/$(pkg).tar.gz \
	    --transform s,^csource,$(pkg)/src, \
	    --transform s,.*debian.mk,Makefile, $(files)
	cp -r $(files)  build/$(pkg)
	#p    $(exe)    build/$(pkg)
	cd       build/$(pkg); debmake
	cd       build/$(pkg); EDITOR=/bin/true dpkg-source --commit . 1
	cd       build/$(pkg); debuild $(opts_debuild1)


zip:   pkg:=pdf-text-parser-0.3
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
