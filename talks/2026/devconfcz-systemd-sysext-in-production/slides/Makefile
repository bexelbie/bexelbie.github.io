# Build sysext-slides.marp-source.md to PPTX/HTML/PDF using marp-cli via npx.
#
# Usage:
#   make            # default: build PPTX (the talk deliverable)
#   make pptx       # build PPTX
#   make html       # build HTML
#   make pdf        # build PDF
#   make all        # build PPTX + HTML + PDF
#   make serve      # live preview server (auto-reload on save)
#   make clean      # delete generated outputs
#   make help       # print this header

SRC      := sysext-slides.marp-source.md
OUT_BASE := sysext-slides

# Anything inside assets/ is also a build input — touching an SVG must
# trigger a rebuild even though the .md itself is unchanged.
ASSETS   := $(wildcard assets/*)
DEPS     := $(SRC) flatcar.css $(ASSETS)

MARP         := npx --yes @marp-team/marp-cli@latest
COMMON_FLAGS := --html --allow-local-files
# --theme-set takes an array, so it greedily swallows the next positional
# argument. Keep it trailing (after -o $@) so it only consumes the ".".
THEME_SET    := --theme-set .

.PHONY: pptx all html pdf serve clean help

# Default target (first one wins in make).
pptx: $(OUT_BASE).pptx

all: $(OUT_BASE).pptx $(OUT_BASE).html $(OUT_BASE).pdf

html: $(OUT_BASE).html
pdf:  $(OUT_BASE).pdf

# $< is always $(SRC) (the first prereq); $(ASSETS) only act as
# timestamp triggers — marp picks them up via the source's <img src>.
$(OUT_BASE).pptx: $(DEPS)
	$(MARP) $(COMMON_FLAGS) --pptx $(SRC) -o $@ $(THEME_SET)

$(OUT_BASE).html: $(DEPS)
	$(MARP) $(COMMON_FLAGS) $(SRC) -o $@ $(THEME_SET)

$(OUT_BASE).pdf: $(DEPS)
	$(MARP) $(COMMON_FLAGS) --pdf $(SRC) -o $@ $(THEME_SET)

serve:
	$(MARP) $(COMMON_FLAGS) --server . $(THEME_SET)

clean:
	rm -f $(OUT_BASE).pptx $(OUT_BASE).html $(OUT_BASE).pdf

help:
	@sed -n '1,12p' $(firstword $(MAKEFILE_LIST))
