GO := go
ROOT_PACKAGE := github.com/marmotedu/api
ifeq ($(origin ROOT_DIR),undefined)
ROOT_DIR := $(shell pwd)
endif

OUTPUT_DIR := $(ROOT_DIR)/_output
PROTOC_INC_PATH=$(dir $(shell which protoc 2>/dev/null))/../include
API_DEPS=proto/apiserver/v1/cache.proto
API_DEPSRCS=$(API_DEPS:.proto=.pb.go)

# Linux command settings                    
FIND := find . ! -path './third_party/*' ! -path './vendor/*'        
XARGS := xargs --no-run-if-empty        

all: verify-copyright test format lint gen

## test: Test the package.
.PHONY: test
test:
	@echo "===========> Testing packages"
	@$(GO) test $(ROOT_PACKAGE)/...

.PHONY: golines.verify
golines.verify:
ifeq (,$(shell which golines 2>/dev/null))
	@echo "===========> Installing golines"
	@$(GO) get -u github.com/segmentio/golines
endif

## format: Format the package with `gofmt`
.PHONY: format
format: golines.verify
	@echo "===========> Formating codes"
	 @$(FIND) -type f -name '*.go' | $(XARGS) gofmt -s -w
	 @$(FIND) -type f -name '*.go' | $(XARGS) goimports -w -local $(ROOT_PACKAGE)
	 @$(FIND) -type f -name '*.go' | $(XARGS) golines -w --max-len=120 --reformat-tags --shorten-comments --ignore-generated .   

.PHONY: lint.verify
lint.verify:
ifeq (,$(shell which golangci-lint 2>/dev/null))
	@echo "===========> Installing golangci lint"
	@$(GO) get -u github.com/golangci/golangci-lint/cmd/golangci-lint
endif

## lint: Check syntax and styling of go sources.
.PHONY: lint
lint: lint.verify
	@echo "===========> Run golangci to lint source codes"
	@golangci-lint run $(ROOT_DIR)/...

.PHONY: copyright.verify
copyright.verify:
ifeq (,$(shell which addlicense 2>/dev/null))
	@echo "===========> Installing addlicense"
	@$(GO) get -u github.com/marmotedu/addlicense
endif

## verify-copyright: Verify the boilerplate headers for all files.
.PHONY: verify-copyright
verify-copyright: copyright.verify
	@echo "===========> Verifying the boilerplate headers for all files"
	@addlicense --check -f $(ROOT_DIR)/boilerplate.txt $(ROOT_DIR) --skip-dirs=third_party

## add-copyright: Ensures source code files have copyright license headers.
.PHONY: add-copyright
add-copyright: copyright.verify
	@addlicense -v -f $(ROOT_DIR)/boilerplate.txt $(ROOT_DIR) --skip-dirs=third_party

.PHONY: updates.verify
updates.verify:
ifeq (,$(shell which go-mod-outdated 2>/dev/null))
	@echo "===========> Installing go-mod-outdated"
	@$(GO) get -u github.com/psampaz/go-mod-outdated
endif

## check-updates: Check outdated dependencies of the go projects.
.PHONY: check-updates
check-updates: updates.verify
	@$(GO) list -u -m -json all | go-mod-outdated -update -direct

## gen: Generate protobuf files.
.PHONY: gen
gen: gen.clean gen.proto

.PHONY: gen.plugin.verify
gen.plugin.verify:
ifeq (,$(shell which protoc-gen-go 2>/dev/null))
	@echo "===========> Installing protoc-gen-go"
	@GO111MODULE=on $(GO) get -u github.com/golang/protobuf/protoc-gen-go
endif

$(API_DEPSRCS): gen.plugin.verify $(API_DEPS)
	@echo "===========> Generate protobuf files"
	@mkdir -p $(OUTPUT_DIR)
	@protoc -I $(PROTOC_INC_PATH) -I. \
	 --experimental_allow_proto3_optional \
	 --go_out=plugins=grpc:$(OUTPUT_DIR) $(@:.pb.go=.proto)
	@cp $(OUTPUT_DIR)/$(ROOT_PACKAGE)/$@ $@ || cp $(OUTPUT_DIR)/$@ $@
	@rm -rf $(OUTPUT_DIR)

.PHONY: gen.proto
 gen.proto: $(API_DEPSRCS)

.PHONY: gen.clean
gen.clean:
	@rm -f $(API_DEPSRCS)

## help: Show this help info.
.PHONY: help
help: Makefile
	@echo -e "\nUsage: make <TARGETS> ...\n\nTargets:"
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo "$$USAGE_OPTIONS"
