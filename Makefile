GO := go
ROOT_PACKAGE := github.com/marmotedu/api
ifeq ($(origin ROOT_DIR),undefined)    
ROOT_DIR := $(shell pwd)
endif    

OUTPUT_DIR := $(ROOT_DIR)/_output
PROTOC_INC_PATH=$(dir $(shell which protoc 2>/dev/null))/../include    
API_DEPS=proto/apiserver/v1/cache.proto    
API_DEPSRCS=$(API_DEPS:.proto=.pb.go)   

all: test format lint boilerplate gen

## test: Test the package.
.PHONY: test
test:
	@echo "===========> Testing packages"
	@$(GO) test $(ROOT_PACKAGE)/...

## format: Format the package with `gofmt`
.PHONY: format
format:  
	@echo "===========> Formating codes"
	@find . -name "*.go" | xargs gofmt -s -w
	@find . -name "*.go" | xargs goimports -w -local $(ROOT_PACKAGE)

.PHONY: lint.verify                                                           
lint.verify:
ifeq (,$(shell which golangci-lint 2>/dev/null))
	@echo "===========> Installing golangci lint"
	@GO111MODULE=off $(GO) get -u github.com/golangci/golangci-lint/cmd/golangci-lint    
endif                       

## lint: Check syntax and styling of go sources.
.PHONY: lint    
lint: lint.verify
	@echo "===========> Run golangci to lint source codes"
	@golangci-lint run $(ROOT_DIR)/...  

.PHONY: license.verify    
license.verify:
	@echo "===========> Verifying the boilerplate headers for all files"
	@$(GO) run $(ROOT_DIR)/tools/addlicense/addlicense.go --check -f $(ROOT_DIR)/boilerplate.txt $(ROOT_DIR) --skip-dirs=third_party
    
.PHONY: license.add    
license.add:
	@$(GO) run $(ROOT_DIR)/tools/addlicense/addlicense.go -v -f $(ROOT_DIR)/boilerplate.txt $(ROOT_DIR) --skip-dirs=third_party

## boilerplate: Verify the boilerplate headers for all files.    
.PHONY: boilerplate    
boilerplate:
	@$(MAKE) license.verify                            
    
## license: Ensures source code files have copyright license headers.               
.PHONY: license    
license:
	@$(MAKE) license.add     

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
