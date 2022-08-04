FROM golang:1.18
WORKDIR /go/src/nearform/3-tiers-serverless
COPY . ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o app .

FROM amd64/alpine:3
RUN apk --no-cache add ca-certificates
WORKDIR /root/
EXPOSE 8080
COPY --from=0 /go/src/nearform/3-tiers-serverless/app ./
CMD ["./app"]
