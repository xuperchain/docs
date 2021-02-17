# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = source
BUILDDIR      = build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile serve  release 

serve:
	docker run --rm -it --name xuperdocs  -p 8000:8000  -v `pwd`/source:/web xuperdocs

build-image:
	docker build -t xuperdocs  .

release :
		docker run --rm -it --name xuperdocs-release   -v `pwd`:`pwd`  -w `pwd`  xuperdocs sphinx-versioning build -r master source source/_build/html

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
