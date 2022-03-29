FROM rust:latest as builder

ARG TARGETPLATFORM

RUN rustc --version &&  rustup --version && cargo --version

#RUN apt update && apt install -y musl-tools
#RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl armv7-unknown-linux-musleabi armv7-unknown-linux-musleabihf

# Create a dummy project and build the app's dependencies.
# If the Cargo.toml or Cargo.lock files have not changed,
# we can use the docker build cache and skip these (typically slow) steps.
RUN USER=root cargo new Hello_Musl_World
WORKDIR /code
COPY Cargo.toml Cargo.lock ./
RUN case $TARGETPLATFORM in\
      linux/amd64)  rust_target="x86_64-unknown-linux-musl";;\
      linux/arm64)  rust_target="aarch64-unknown-linux-musl";;\
      linux/arm/v7) rust_target="armv7-unknown-linux-musleabihf";;\
      linux/arm/v6) rust_target="arm-unknown-linux-musleabi";;\
      *)            exit 1;;\
    esac &&\
    rustup target add ${rust_target} &&\
    cargo build --target ${rust_target} --release

COPY src /code/src
RUN RUN case $TARGETPLATFORM in\
      linux/amd64)  rust_target="x86_64-unknown-linux-musl";;\
      linux/arm64)  rust_target="aarch64-unknown-linux-musl";;\
      linux/arm/v7) rust_target="armv7-unknown-linux-musleabihf";;\
      linux/arm/v6) rust_target="arm-unknown-linux-musleabi";;\
      *)            exit 1;;\
    esac &&\
    cargo install --target ${rust_target} --path .

# second stage.
FROM scratch

# copy server binary from build stage
COPY --from=builder /code/target/release/Hello_Musl_World /app/Hello_Musl_World

LABEL author="Slundi"
LABEL url="https://github.com/slundi/rust-musl-docker-buld-multi-arch"
LABEL vcs-url="https://github.com/slundi/rust-musl-docker-buld-multi-arch"
# set user to non-root unless root is required for your app
ENTRYPOINT [ "/app/Hello_Musl_World}]
