GOSOURCES := $(shell find . \( -name '*.go' \))
TEMPLATES := $(shell find tmpl/templates \( -name '*.tmpl' \))

THISFILE := $(lastword $(MAKEFILE_LIST))
THISDIR  := $(shell dirname $(realpath $(THISFILE)))
GOBIN    := $(THISDIR)/bin

# Prepend this repo's bin directory to our path since we'll want to
# install some build tools there for use during the build process.
PATH := $(GOBIN):$(PATH)

# Export GOBIN env variable so `go install` picks it up correctly.
export GOBIN

all:

clean:
	-rm bin/phenix
	-rm tmpl/bindata.go

.PHONY: install-build-deps
install-build-deps: bin/go-bindata

.PHONY: remove-build-deps
remove-build-deps:
	$(RM) bin/go-bindata

bin/go-bindata:
	go install github.com/go-bindata/go-bindata/v3/go-bindata

tmpl/bindata.go: $(TEMPLATES) bin/go-bindata
	$(GOBIN)/go-bindata -pkg tmpl -prefix tmpl/templates -o tmpl/bindata.go tmpl/templates/...

bin/phenix: $(GOSOURCES) tmpl/bindata.go
	mkdir -p bin
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags="-s -w" -trimpath -o bin/phenix cmd/main.go
