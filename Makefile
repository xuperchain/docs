# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = source
BUILDDIR      = _build

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile serve  release 

build:
	docker run --rm -it --name xuperdocs  -p 8000:8000  -v `pwd`:`pwd` -w `pwd`  xuperdocs make html
	
serve:
	docker run --rm -it --name xuperdocs  -p 8000:8000  -v `pwd`/source:/web xuperdocs

lint:
	docker run --rm -it --name xuperdocs  -p 8000:8000  -v `pwd`:/web xuperdocs doc8 --ignore D001 --ignore D000 --ignore D002 --ignore D004 --ignore D003 source

build-image:
	docker build -t xuperdocs  .
	
release :
	docker run --rm --name xuperdocs-release   -v `pwd`:`pwd`  -w `pwd`  xuperdocs sphinx-versioning build -r master source source/_build/html

stop:
	docker stop xuperdocs

clean:
	rm -rf _build
	rm -rf source/_build

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
