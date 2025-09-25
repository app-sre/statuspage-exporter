# AI Agent Context

## Project Overview
This is statuspage-exporter, a Prometheus exporter for monitoring statuspage.io components written in Go. The project exports metrics about component statuses to Prometheus for monitoring and alerting.

## Key Technologies
- Go
- Prometheus client library
- HTTP server for metrics endpoint

## Project Structure
- `cmd/statuspage-exporter/main.go` - Main application entry point
- `pkg/collectors/` - Prometheus collectors for metrics
- `pkg/config/` - Configuration handling
- `pkg/api/` - API types and structures
- `Makefile` - Build and test commands
- `Dockerfile` - Container build configuration

## Development Workflow
- Build: `make build`
- Test: `make test` (includes go vet and unit tests)
- Run locally: `make run` (requires env.sh with PAGE_ID)
- Container: `make image`

## Important Notes
- Uses Prometheus registry for metrics collection
- Serves metrics on port 9101 at `/metrics` endpoint
- Requires PAGE_ID environment variable for operation
- Follow Go best practices and existing code patterns
- Ensure all changes pass `go vet` and unit tests
