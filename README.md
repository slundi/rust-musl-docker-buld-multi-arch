# rust-musl-docker-buld-multi-arch
CI on Docker Hub for Rust app

## Why?

I was trying to build and deploy another app on Docker Hub using GitHub Actions but after multiple tries it does not work (yet).
So, I made this repository in order to:

* Avoid unecessary commits on my main application
* Have a model for my future projects

Best practices for Docker building are saying to use `BUILDPLATFORM` and `TARGETPLATFORM` arguments.
But, Rust can build any target platform using `cargo build --target`.
