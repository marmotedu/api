module github.com/marmotedu/api

go 1.16

require (
	github.com/golang/protobuf v1.5.1
	github.com/marmotedu/component-base v0.0.0-00010101000000-000000000000
	github.com/ory/ladon v1.2.0
	github.com/spf13/pflag v1.0.5
	golang.org/x/sync v0.0.0-20210220032951-036812b2e83c
	google.golang.org/grpc v1.36.0
	google.golang.org/protobuf v1.26.0
	gorm.io/gorm v1.21.4
)

replace (
	github.com/marmotedu/api => /home/colin/workspace/golang/src/github.com/marmotedu/api
	github.com/marmotedu/component-base => /home/colin/workspace/golang/src/github.com/marmotedu/component-base
	github.com/marmotedu/errors => /home/colin/workspace/golang/src/github.com/marmotedu/errors
	github.com/marmotedu/marmotedu-sdk-go => /home/colin/workspace/golang/src/github.com/marmotedu/marmotedu-sdk-go
)
