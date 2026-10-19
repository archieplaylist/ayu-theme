# Build image for ayu-theme release tarballs.
#
# Only the build toolchain is installed here: the theme itself is copied in at
# run time so the same image can build both the transparent and solid variants.

FROM debian:bookworm-slim

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		autoconf \
		automake \
		pkg-config \
		sassc \
		make \
		ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /build
