# Chef for fast builds
FROM lukemathwalker/cargo-chef:latest AS chef
WORKDIR app

# Planner will create a recipe for future build
FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

# Builder will build a project from recipe
FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release --bin rust-api

# Runtime is a minimal size container for run only compiled executable
FROM debian:bullseye-slim AS runtime
WORKDIR app
COPY --from=builder /app/target/release/rust-api /usr/local/bin
ENTRYPOINT ["/usr/local/bin/rust-api"]

# Watcher only installs cargo-watch to skip that installation in every run
FROM rust:latest AS watcher
WORKDIR app
RUN cargo install cargo-watch

# Dev activates cargo-watch to restart "cargo run" command on file change
FROM watcher AS dev
COPY . .
CMD cargo watch --poll -x "run"