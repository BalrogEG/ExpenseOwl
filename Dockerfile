FROM golang:1.24-alpine AS builder
# AiX build egress has no proxy.golang.org / sum.golang.org: fetch the two
# GitHub-hosted modules (google/uuid, lib/pq) directly with git; go.sum still pins them.
RUN apk add --no-cache git
ENV GOPROXY=direct GOSUMDB=off CGO_ENABLED=0 GOTOOLCHAIN=local
WORKDIR /app
COPY . .
RUN go build -o expenseowl ./cmd/expenseowl

FROM alpine:3.22
WORKDIR /app
RUN mkdir -p /app/data
COPY --from=builder /app/expenseowl .
EXPOSE 3000
CMD ["./expenseowl", "-port", "3000"]
