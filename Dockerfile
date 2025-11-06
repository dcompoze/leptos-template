FROM rustlang/rust:nightly-alpine as builder

RUN apk update && apk add --no-cache bash curl npm libc-dev binaryen

RUN npm install -g tailwindcss

RUN curl --proto '=https' --tlsv1.3 -LsSf https://github.com/leptos-rs/cargo-leptos/releases/latest/download/cargo-leptos-installer.sh | sh

RUN rustup target add wasm32-unknown-unknown

WORKDIR /project
COPY . .

RUN cargo leptos build --release -vv

FROM rustlang/rust:nightly-alpine as runner

WORKDIR /app

COPY --from=builder /project/target/release/leptos_start /app/
COPY --from=builder /project/target/site /app/site
COPY --from=builder /project/Cargo.toml /app/

ENV RUST_LOG="info"
ENV LEPTOS_SITE_ADDR="0.0.0.0:8080"
ENV LEPTOS_SITE_ROOT=./site
EXPOSE 8080

CMD ["/app/leptos_start"]
