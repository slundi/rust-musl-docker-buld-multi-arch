FROM ekidd/rust-musl-builder:latest as builder

# We need to add the source code to the image because `rust-musl-builder`
# assumes a UID of 1000, but TravisCI has switched to 2000.
ADD --chown=rust:rust . ./

#FROM rust:latest as builder

ARG TARGETPLATFORM

RUN rustc --version &&  rustup --version && cargo --version

WORKDIR /home/rust

COPY . ./
RUN cargo build --release

# second stage.
FROM scratch

# copy server binary from build stage
COPY --from=builder /home/rust/target/release/Hello_Musl_World /app/Hello_Musl_World

LABEL author="Slundi"
LABEL url="https://github.com/slundi/rust-musl-docker-buld-multi-arch"
LABEL vcs-url="https://github.com/slundi/rust-musl-docker-buld-multi-arch"
# set user to non-root unless root is required for your app
ENTRYPOINT [ "/app/Hello_Musl_World}]
