MODULE:=baetyl-core
SRC_FILES:=$(shell find . -type f -name '*.go')
BIN_FILE:=baetyl-core
BIN_CMD=$(shell echo $(@:$(OUTPUT)/%/$(MODULE)/bin/$(BIN_FILE)=%)  | sed 's:/v:/:g' | awk -F '/' '{print "CGO_ENABLED=0 GOOS="$$1" GOARCH="$$2" GOARM="$$3" go build"}') -o $@ ${GO_FLAGS} .
COPY_DIR:=../output
PLATFORM_ALL:=darwin/amd64 linux/amd64 linux/arm64 linux/386 linux/arm/v7 linux/arm/v6 linux/arm/v5 linux/ppc64le linux/s390x


GIT_TAG:=$(shell git tag --contains HEAD)
GIT_REV:=git-$(shell git rev-parse --short HEAD)
VERSION:=$(if $(GIT_TAG),$(GIT_TAG),$(GIT_REV))

ifndef PLATFORMS
	GO_OS:=$(shell go env GOOS)
	GO_ARCH:=$(shell go env GOARCH)
	GO_ARM:=$(shell go env GOARM)
	PLATFORMS:=$(if $(GO_ARM),$(GO_OS)/$(GO_ARCH)/$(GO_ARM),$(GO_OS)/$(GO_ARCH))
	ifeq ($(GO_OS),darwin)
		PLATFORMS+=linux/amd64
	endif
else ifeq ($(PLATFORMS),all)
	override PLATFORMS:=$(PLATFORM_ALL)
endif

REGISTRY?=
XFLAGS?=--load
XPLATFORMS:=$(shell echo $(filter-out darwin/amd64,$(PLATFORMS)) | sed 's: :,:g')

YML_FILE=$(wildcard *.yml)
RES_DIR=$(wildcard server/*.template)

OUTPUT:=./output
OUTPUT_MODS:=$(PLATFORMS:%=$(OUTPUT)/%/$(MODULE))
OUTPUT_BINS:=$(OUTPUT_MODS:%=%/bin/$(BIN_FILE))
OUTPUT_PKGS:=$(OUTPUT_MODS:%=%/$(MODULE)-$(VERSION).zip) # TODO: switch to tar

.PHONY: all
all: $(OUTPUT_BINS) $(OUTPUT_PKGS)

$(OUTPUT_BINS): $(SRC_FILES)
	@echo "BUILD $@"
	@install -d -m 0755 $(dir $@)
	$(BIN_CMD)

$(OUTPUT_PKGS): $(OUTPUT_BINS) $(YML_FILE)
	@echo "PACKAGE $@"
	@install -m 0755 $(YML_FILE) $(dir $@)
	@install -d -m 0755 $(dir $@)/server
	@install -m 0755 $(RES_DIR) $(dir $@)/server
	@cd $(dir $@) && zip -q -r $(notdir $@) bin $(YML_FILE)

.PHONY: image
image: $(OUTPUT_BINS)
	@echo "BUILDX: $(REGISTRY)$(MODULE):$(VERSION)"
	@-docker buildx create --name baetyl
	@docker buildx use baetyl
	docker buildx build $(XFLAGS) --platform $(XPLATFORMS) -t $(REGISTRY)$(MODULE):$(VERSION) -f Dockerfile $(COPY_DIR)

.PHONY: rebuild
rebuild: clean all

.PHONY: clean
clean:
	@find $(OUTPUT) -type d -name $(MODULE) | xargs rm -rf


