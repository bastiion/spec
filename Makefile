# Variables
VERSION=1.1-draft
HUMAN_VERSION="1.1 Entwurf"
OPARL_LANG?=de
BASENAME=OParl-$(VERSION)-$(OPARL_LANG)

# Directories
SRC_DIR=$(OPARL_LANG)
LOCALIZED_ASSETS=$(OPARL_LANG)/assets
SHM_DIR=schema
EXP_DIR=examples
OUT_DIR=out
ARC_DIR=archives
ASS_DIR=assets

# Commands
PANDOC=pandoc
DOT=dot
LATEX=xelatex
GS=gs
CONVERT=convert
PYTHON=python3

# Command Flags
# ---
# The default flags for the commands are separated from the
# command binaries to simplify switching out the binary for
# a command with environment variables. For instance, one might
# want to use a not-in-path variant of pandoc and this way,
# the make call can simply be prefixed as `PANDOC=/path/to/pandoc make`

PANDOC_FLAGS=--from markdown --standalone --table-of-contents \
	--toc-depth=2 --number-sections
GS_FLAGS=-dQUIET -dSAFER -dBATCH -dNOPAUSE -sDisplayHandle=0 \
	-sDEVICE=png16m -r600 -dTextAlphaBits=4

LATEX_TEMPLATE=$(ASS_DIR)/template.tex
HTML5_CSS=$(ASS_DIR)/html5.css
SCHEMA_MD=$(SRC_DIR)/3-99-schema.md

PDF_IMAGES=$(wildcard $(LOCALIZED_ASSETS)/*.pdf)
GS_IMAGES=$(PDF_IMAGES:.pdf=.png)

SVG_IMAGES=$(wildcard $(LOCALIZED_ASSETS)/*.svg)
MAGICK_IMAGES=$(SVG_IMAGES:.svg=.png)

DOT_IMAGES=$(wildcard $(LOCALIZED_ASSETS)/*.dot)
GRAPHVIZ_IMAGES=$(DOT_IMAGES:.dot=.png)

SCHEMA_JSON=$(wildcard $(SHM_DIR)/*.json)
JSON_TRANSLATIONS=$(OPARL_LANG)/schema.yml

.PHONY: all clean test live html pdf odt txt epub

all: html pdf odt docx txt epub

# preliminary targets

# transform dot file using dot -Tpng graphviz.dot -o graphviz.png
$(LOCALIZED_ASSETS)/%.png: $(LOCALIZED_ASSETS)/%.dot
	$(DOT) -Tpng $< -o $@

$(LOCALIZED_ASSETS)/%.png: $(LOCALIZED_ASSETS)/%.pdf
	$(GS) $(GS_FLAGS) -sOutputFile=$@ -f $<

$(LOCALIZED_ASSETS)/%.png: $(LOCALIZED_ASSETS)/%.svg
	$(CONVERT) $< $@

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(SCHEMA_MD): $(SHM_DIR)/*.json $(EXP_DIR)/*.json scripts/json_schema2markdown.py $(JSON_TRANSLATIONS)
	$(PYTHON) scripts/json_schema2markdown.py $(SHM_DIR) $(EXP_DIR) $(SCHEMA_MD) $(JSON_TRANSLATIONS)

# main targets

common: $(OUT_DIR) $(SCHEMA_MD) $(GS_IMAGES) $(MAGICK_IMAGES) $(GRAPHVIZ_IMAGES)

html: common
	$(PANDOC) $(PANDOC_FLAGS) --to html5 --css $(HTML5_CSS) --section-divs --self-contained \
	    -o $(OUT_DIR)/$(BASENAME).html $(LOCALIZED_ASSETS)/lizenz-als-bild.md $(SRC_DIR)/*.md

pdf: common
	$(PANDOC) $(PANDOC_FLAGS) --latex-engine=$(LATEX) --template $(LATEX_TEMPLATE) \
			-o $(OUT_DIR)/$(BASENAME).pdf $(SRC_DIR)/*.md

odt: common
	$(PANDOC) $(PANDOC_FLAGS) -o $(OUT_DIR)/$(BASENAME).odt $(LOCALIZED_ASSETS)/lizenz-als-text.md $(SRC_DIR)/*.md

docx: common # FIXME: License information in header is missing
	$(PANDOC) $(PANDOC_FLAGS) -o $(OUT_DIR)/$(BASENAME).docx $(LOCALIZED_ASSETS)/lizenz-als-text.md $(SRC_DIR)/*.md

txt: common
	$(PANDOC) $(PANDOC_FLAGS) -o $(OUT_DIR)/$(BASENAME).txt $(SRC_DIR)/*.md

epub: common
	$(PANDOC) $(PANDOC_FLAGS) -o $(OUT_DIR)/$(BASENAME).epub $(SRC_DIR)/*.md

# Used for the spec website
live: common
	$(PANDOC) $(PANDOC_FLAGS) --to html5 --section-divs --no-highlight \
			-o $(OUT_DIR)/live.html $(SRC_DIR)/*.md

clean:
	rm -rf $(OUT_DIR)
	rm -f  $(CONTRIB_MD)
	rm -f  $(SCHEMA_MD)
	rm -f  $(GS_IMAGES)
	rm -f  $(MAGICK_IMAGES)
	rm -rf $(ARC_DIR)

# archives

archives: zip gz bz

zip: all
	mkdir -p $(ARC_DIR) && cd $(OUT_DIR) && zip -qr ../$(ARC_DIR)/$(BASENAME).zip .

gz: all
	mkdir -p $(ARC_DIR) && cd $(OUT_DIR) && tar -czf ../$(ARC_DIR)/$(BASENAME).tar.gz .

bz: all
	mkdir -p $(ARC_DIR) && cd $(OUT_DIR) && tar -cjf ../$(ARC_DIR)/$(BASENAME).tar.bz2 .

# test

test:
	scripts/test.sh
