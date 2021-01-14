# api

Schema of the API types that are served by the IAM API server.

## Purpose

This library is the canonical location of the IAM API definition. Most likely interaction with this repository is as a dependency of marmotedu-sdk-go.

It is published separately to avoid diamond dependency problems for users who
depend on more than one of `github.com/marmotedu/marmotedu-sdk-go`, `github.com/marmotedu/component-base`

## Compatibility

Branches track IAM branches and are compatible with that repo.
