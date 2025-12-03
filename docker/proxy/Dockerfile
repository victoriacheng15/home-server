FROM golang:1.25-alpine

# Install ca-certificates for HTTPS
RUN apk --no-cache add ca-certificates

# Set working directory
WORKDIR /app

# Copy entire proxy directory from build context
COPY proxy/* .

# Build the binary
RUN go build -o health-proxy .

EXPOSE 8085

CMD ["./health-proxy"]