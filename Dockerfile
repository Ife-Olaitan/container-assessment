# Build Stage - Compile the Go application
FROM golang:1.25.5-alpine AS builder

WORKDIR /build

# Copy and download dependencies first (for Docker caching)
COPY MuchToDo/go.mod MuchToDo/go.sum ./
RUN go mod download

# Copy source code
COPY MuchToDo/ ./

# Build the binary
RUN go build -o main ./cmd/api/main.go


# Runtime Stage - Run the application
FROM alpine:latest AS runtime

# Install curl for health checks
RUN apk --no-cache add ca-certificates curl

# Create non-root user
RUN adduser -D -u 1000 appuser

WORKDIR /app

# Copy binary from build stage
COPY --from=builder /build/main .
COPY --from=builder /build/docs ./docs
#COPY --from=builder /build/.env .

# Use non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check with curl
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/health || exit 1

# Run the app
CMD ["./main"]