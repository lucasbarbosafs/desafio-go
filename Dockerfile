FROM golang:1.21.3 AS BUILDER

WORKDIR /usr/src/app

COPY fullcycle.go /usr/src/app

RUN go mod init fullcycle && go build fullcycle.go

FROM scratch

WORKDIR /usr/src/app

COPY --from=BUILDER /usr/src/app /usr/src/app

ENTRYPOINT [ "./fullcycle" ]