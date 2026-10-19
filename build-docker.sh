#!/usr/bin/env bash
#
# Build ayu-theme in Docker and emit release tarballs into ./dist.
#
#   ./build-docker.sh                # transparent variants -> dist/ayu-theme-<ver>.tar.gz
#   ./build-docker.sh --solid        # solid variants       -> dist/ayu-theme-<ver>-solid.tar.gz
#   ./build-docker.sh --all          # both of the above
#
# Options:
#   -o, --output DIR   output directory (default: ./dist)
#   --image NAME       docker image tag (default: ayu-theme-builder)
#   --keep-image       keep the build image after the run
#   -h, --help         show this help
#
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "$SCRIPT_DIR"

OUT_DIR="$SCRIPT_DIR/dist"
IMAGE=ayu-theme-builder
KEEP_IMAGE=0
BUILD_TRANSPARENT=1
BUILD_SOLID=0

usage() {
	sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

die() {
	printf 'error: %s\n' "$*" >&2
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
		--solid)
			BUILD_TRANSPARENT=0
			BUILD_SOLID=1
			;;
		--all)
			BUILD_TRANSPARENT=1
			BUILD_SOLID=1
			;;
		-o|--output)
			[ $# -ge 2 ] || die "$1 needs a directory"
			OUT_DIR=$2
			shift
			;;
		--image)
			[ $# -ge 2 ] || die "$1 needs a name"
			IMAGE=$2
			shift
			;;
		--keep-image)
			KEEP_IMAGE=1
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			die "unknown option: $1 (try --help)"
			;;
	esac
	shift
done

command -v docker >/dev/null 2>&1 || die "docker is not installed or not in PATH"
docker info >/dev/null 2>&1 || die "cannot talk to the Docker daemon"

mkdir -p "$OUT_DIR"
OUT_DIR=$(cd "$OUT_DIR" && pwd)

printf '==> Building Docker image %s\n' "$IMAGE"
# The image only needs the toolchain, so keep the build context to docker/.
docker build -q -f "$SCRIPT_DIR/docker/Dockerfile" -t "$IMAGE" "$SCRIPT_DIR/docker"

# Files written to a bind mount must end up owned by the invoking user. With
# rootful Docker that means running as $UID; with rootless Docker (where
# container root maps to the host user) --user would only make the mount
# read-only, so probe first.
USER_ARGS=(--user "$(id -u):$(id -g)")
if ! docker run --rm "${USER_ARGS[@]}" -v "$OUT_DIR:/out" "$IMAGE" \
	sh -c 'touch /out/.ayu-write-test && rm /out/.ayu-write-test' >/dev/null 2>&1; then
	USER_ARGS=()
fi

build_variant() {
	local solid=$1
	printf '\n==> Building %s variants\n' \
		"$([ "$solid" = 1 ] && echo solid || echo transparent)"
	docker run --rm \
		"${USER_ARGS[@]}" \
		-e HOME=/tmp \
		-e SRC=/src \
		-e OUT=/out \
		-e SOLID="$solid" \
		-v "$SCRIPT_DIR:/src:ro" \
		-v "$OUT_DIR:/out" \
		"$IMAGE" \
		/src/docker/build.sh
}

if [ "$BUILD_TRANSPARENT" = 1 ]; then
	build_variant 0
fi
if [ "$BUILD_SOLID" = 1 ]; then
	build_variant 1
fi

if [ "$KEEP_IMAGE" = 0 ]; then
	docker image rm "$IMAGE" >/dev/null 2>&1 || true
fi

printf '\n==> Artifacts in %s\n' "$OUT_DIR"
ls -lh "$OUT_DIR"
