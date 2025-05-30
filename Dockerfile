FROM golang:1.21 AS build

WORKDIR /app

COPY go.mod .
COPY go.sum .
RUN go mod download
COPY . .

ARG version
ARG git_commit
ENV VERSION=$version
ENV GIT_COMMIT=$git_commit

# SY errors out obtaining VCS status: exit status 128
RUN CGO_ENABLED=0 go build -buildvcs=false -o /shipyard \
    -ldflags "-s -w -X github.com/khulnasoft-lab/shipyard/version.Version=${VERSION} -X github.com/khulnasoft-lab/shipyard/version.GitCommit=${GIT_COMMIT}"

FROM alpine:3.22
COPY --from=build /shipyard /usr/local/bin
