PAPERTYPE=A4

VERSION=$(shell ./get-version.sh ChangeLog)

DB_XSL_BASE=http://docbook.sourceforge.net/release/xsl/current
DB_TITLE_XSL=$(DB_XSL_BASE)/template/titlepage.xsl
DB_MAN_XSL=$(DB_XSL_BASE)/manpages/docbook.xsl
DB_HTML_XSL=$(DB_XSL_BASE)/html/docbook.xsl

DBSRC=doc/chapter-intro.xml doc/chapter-language.xml doc/chapter-security.xml \
      doc/chapter-troubleshooting.xml doc/firehol-manual.xml

DBGEN=doc/services-list.xml doc/manual-info.xml

OUT=build/firehol-$(VERSION)

TAR=dist/firehol-$(VERSION).tar.gz

HTMLDOC=$(OUT)/doc/firehol-manual.html $(OUT)/doc/firehol-services.html \
        $(OUT)/doc/firehol-manual.css
PDFDOC=$(OUT)/doc/firehol-manual.pdf
MANDOC=$(OUT)/man/man1/firehol.1

BASEFILES=firehol INSTALL README COPYING ChangeLog
ADMINFILES=admin/adblock.sh admin/prettyconf.sh
EXAMPLES=examples/bittorrent.conf examples/lan-gateway.conf \
         examples/server-dmz.conf examples/client-all.conf \
         examples/office.conf

$(TAR): $(OUT)/firehol $(HTMLDOC) $(PDFDOC) $(MANDOC)
	mkdir -p dist
	tar cpCfz build $(TAR) firehol-$(VERSION) --owner=root --group=root

$(OUT)/firehol: $(BASEFILES)
	mkdir -p build/tmp
	install -m 755 -d $(OUT)
	install -m 755 -d $(OUT)/admin
	install -m 755 -d $(OUT)/doc
	install -m 755 -d $(OUT)/examples
	install -m 755 -d $(OUT)/man
	install -m 755 -d $(OUT)/man/man1
	install -m 755 -d $(OUT)/man/man5
	install -m 644 admin/* $(OUT)/admin
	install -m 644 examples/* $(OUT)/examples
	install -m 644 INSTALL $(OUT)
	install -m 644 README $(OUT)
	install -m 644 COPYING $(OUT)
	gzip -c9 ChangeLog > build/tmp/ChangeLog.gz
	install -m 644 build/tmp/ChangeLog.gz $(OUT)
	sed -e 's/VERSION=DEVELOPMENT/VERSION=$(VERSION)/' firehol > build/tmp/firehol
	install -m 755 build/tmp/firehol $(OUT)/firehol

build/tmp/titlepage-fo.xsl: $(OUT)/firehol doc/titlepage-fo.xml
	xsltproc --nonet --stringparam ns http://www.w3.org/1999/XSL/Format --output build/tmp/titlepage-fo.xsl $(DB_TITLE_XSL) doc/titlepage-fo.xml

doc/services-list.xml: doc/services-db.txt $(OUT)/firehol
	doc/mkservicelist.pl doc/services-list.xml $(OUT)/firehol doc/services-db.txt

doc/manual-info.xml: doc/manual-info.txt ChangeLog
	doc/mkbookinfo.pl doc/manual-info.xml ChangeLog doc/manual-info.txt

build/tmp/db-valid: $(DBSRC) $(DBGEN)
	xmllint --nonet --noout --postvalid --xinclude doc/firehol-manual.xml
	touch build/tmp/db-valid

$(OUT)/man/man1/firehol.1: build/tmp/db-valid $(OUT)/firehol
	xsltproc --nonet --output build/tmp --xinclude --param man.output.in.separate.dir 1 --param man.output.subdirs.enabled 1 $(DB_MAN_XSL) doc/firehol-manual.xml
	sed -i -e "s;.so man/man;.so man;" build/man/man*/*
	install -m 644 build/man/man1/* $(OUT)/man/man1
	install -m 644 build/man/man5/* $(OUT)/man/man5

$(OUT)/doc/firehol-manual.css: $(OUT)/doc/firehol-manual.html doc/firehol-manual.css
	cp doc/firehol-manual.css $(OUT)/doc/
	chmod 644 $(OUT)/doc/firehol-manual.css

$(OUT)/doc/firehol-services.html: $(OUT)/firehol
	doc/mkhtmlindex.pl $(OUT)/doc/firehol-services.html $(OUT)/firehol
	chmod 644 $(OUT)/doc/firehol-services.html

$(OUT)/doc/firehol-manual.html: build/tmp/db-valid $(OUT)/firehol
	xsltproc --nonet --xinclude --stringparam html.stylesheet.type text/css --stringparam html.stylesheet firehol-manual.css --param generate.index 0 -o $(OUT)/doc/firehol-manual.html $(DB_HTML_XSL) doc/firehol-manual.xml
	chmod 644 $(OUT)/doc/firehol-manual.html

build/tmp/firehol-manual.fo: build/tmp/db-valid $(OUT)/firehol build/tmp/titlepage-fo.xsl doc/pdf.xsl
	xsltproc --nonet --xinclude --stringparam paper.type $(PAPERTYPE) -o build/tmp/firehol-manual.fo doc/pdf.xsl doc/firehol-manual.xml

$(OUT)/doc/firehol-manual.pdf: build/tmp/firehol-manual.fo
	fop build/tmp/firehol-manual.fo -pdf $(OUT)/doc/firehol-manual.pdf
	chmod 644 $(OUT)/doc/firehol-manual.pdf

clean:
	rm -f doc/services-list.xml doc/manual-info.xml
	rm -rf build
