# syntax=docker/dockerfile:1.4

########################
# 1. Build with Go     #
########################
FROM golang:1.23-alpine AS builder
LABEL stage=builder

# Install git, ca-certificates
RUN apk add --no-cache git ca-certificates

WORKDIR /src

# Copy go.mod/go.sum first for caching
COPY go.mod go.sum ./
RUN go mod download

# Copy rest of the source
COPY . .

# Build the backhaul binary (static)
RUN CGO_ENABLED=0 \
    go build -ldflags="-s -w" \
    -o /out/backhaul ./main.go

#########################
# 2. Create final image #
#########################
FROM alpine:3.18 AS runtime
RUN apk add --no-cache ca-certificates

WORKDIR /app

# Copy the built binary
COPY --from=builder /out/backhaul .

# Final entrypoint
ENTRYPOINT ["./backhaul"]
