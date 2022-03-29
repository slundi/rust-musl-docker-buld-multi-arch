FROM --platform=linux/amd64 rust:latest as builder

ARG TARGETPLATFORM

RUN apt update && apt install -y musl-tools
#RUN rustup target add x86_64-unknown-linux-musl aarch64-unknown-linux-musl armv7-unknown-linux-musleabi armv7-unknown-linux-musleabihf

RUN rustc --version &&  rustup --version && cargo --version

WORKDIR /code

# Download crates-io index and fetch dependency code.
# This step avoids needing to spend time on every build downloading the index
# which can take a long time within the docker context. Docker will cache it.
#RUN USER=root cargo init
COPY ./ /code

# build dependencies, when my source code changes, this build can be cached, we don't need to compile dependency again.
#RUN cargo clean && cargo build --release
RUN case $TARGETPLATFORM in\
      linux/amd64)  rust_target="x86_64-unknown-linux-musl";;\
      linux/arm64)  rust_target="aarch64-unknown-linux-musl";;\
      linux/arm/v7) rust_target="armv7-unknown-linux-musleabihf";;\
      linux/arm/v6) rust_target="arm-unknown-linux-musleabi";;\
      *)            exit 1;;\
    esac &&\
    rustup target add ${rust_target} &&\
    RUSTFLAGS=-Clinker=musl-gcc cargo build --target ${rust_target} --release &&\
    rm -f target/${rust_target}/release/deps/Hello_Musl_World

# second stage.
FROM scratch
WORKDIR /data
ENV WEBROOT=/
# copy server binary from build stage
COPY --from=builder /code/target/release/Hello_Musl_World /app/Hello_Musl_World

LABEL author="Slundi"
LABEL url="https://github.com/slundi/rust-musl-docker-buld-multi-arch"
LABEL vcs-url="https://github.com/slundi/rust-musl-docker-buld-multi-arch"
# set user to non-root unless root is required for your app
ENTRYPOINT [ "/app/Hello_Musl_World}]
