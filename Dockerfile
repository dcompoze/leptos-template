FROM rust:1.91.0-bookworm as builder

RUN wget https://github.com/cargo-bins/cargo-binstall/releases/latest/download/cargo-binstall-x86_64-unknown-linux-musl.tgz
RUN tar -xvf cargo-binstall-x86_64-unknown-linux-musl.tgz
RUN mv cargo-binstall /usr/local/cargo/bin

RUN apt-get update -y && apt-get install -y --no-install-recommends \
	libssl-dev libpq-dev pkg-config build-essential clang curl libclang-dev \
	librocksdb-dev protobuf-compiler libudev1 libudev-dev mold git tree npm

RUN rm -rf /var/lib/apt/lists/*
ENV CARGO_HOME=/root/.cargo

RUN cargo binstall sccache -y
RUN cargo binstall cargo-leptos -y

RUN curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v4.1.16/tailwindcss-linux-x64
RUN mv ./tailwindcss-linux-x64 /usr/local/bin/tailwindcss && chmod +x /usr/local/bin/tailwindcss

RUN rustup target add wasm32-unknown-unknown

WORKDIR /project
COPY . .

RUN tailwindcss -i tailwind.css -o style/main.css --optimize --minify
RUN cargo leptos build --release -vv

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libpq5 ca-certificates && update-ca-certificates

WORKDIR /app

COPY --from=builder /project/target/release/{{project-name}} /app/
COPY --from=builder /project/target/site /app/site
COPY --from=builder /project/Cargo.toml /app/

ENV RUST_LOG="info"
ENV LEPTOS_SITE_ADDR="0.0.0.0:80"
ENV LEPTOS_SITE_ROOT=./site
EXPOSE 80

CMD ["/app/{{project-name}}"]
