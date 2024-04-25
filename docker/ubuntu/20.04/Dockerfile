# syntax=docker/dockerfile:1

#
# Building chan_quectel on Ubuntu 20.04
#
ARG DEBIAN_FRONTEND=noninteractive
ARG CC_TARGET=amd64
ARG CC_TOOLCHAIN=arm-linux-gnueabihf
ARG ARM_GNU_TOOLCHAIN_VER=13.2.rel1

FROM scratch AS dl-task
ADD --chmod=444 http://github.com/go-task/task/releases/latest/download/task_linux_amd64.deb .

FROM ubuntu:20.04 AS task-base
ARG DEBIAN_FRONTEND
RUN --network=none mkdir /build
RUN --network=none --mount=type=bind,from=dl-task,target=/build/download dpkg --install /build/download/task_linux_amd64.deb
COPY --from=task --chown=nobody:nogroup Taskfile.dist.yaml /build/Taskfile.yaml
COPY --from=task deb /build/task.d/deb

FROM scratch AS dl-arm-gnu-toolchain
ARG ARM_GNU_TOOLCHAIN_VER
ADD --chmod=444 http://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/${ARM_GNU_TOOLCHAIN_VER}/binrel/arm-gnu-toolchain-${ARM_GNU_TOOLCHAIN_VER}-x86_64-arm-none-linux-gnueabihf.tar.xz .
ADD --chmod=444 http://armkeil.blob.core.windows.net/developer/Files/downloads/gnu/${ARM_GNU_TOOLCHAIN_VER}/binrel/arm-gnu-toolchain-${ARM_GNU_TOOLCHAIN_VER}-x86_64-aarch64-none-linux-gnu.tar.xz .

FROM task-base AS arm-gnu-toolchain
ARG ARM_GNU_TOOLCHAIN_VER

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    task -d /build/task.d/deb install-pkgs -- xz-utils
COPY --from=task arm-gnu-toolchain /build/task.d/arm-gnu-toolchain
RUN --network=none task -d /build/task.d/arm-gnu-toolchain create-directory

USER nobody:nogroup
RUN --network=none --mount=type=bind,from=dl-arm-gnu-toolchain,target=/build/download task -d /build/task.d/arm-gnu-toolchain prepare

FROM task-base AS base
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked -- \
    task -d /build/task.d/deb install-pkgs -- file build-essential ca-certificates jq dpkg-dev libsqlite3-dev libssl1.1
RUN --network=none task -d /build create-build-directory && \
    task -d /build/task.d/deb create-dotenv && \
    task -d /build chown-build-directory -- nobody:nogroup

FROM scratch as dl-cmake
ADD --chmod=444 https://api.github.com/repos/Kitware/CMake/releases/latest cmake-latest.json

FROM base as cmake

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    task -d /build/task.d/deb install-pkgs -- libssl-dev curl
COPY --from=task cmake /build/task.d/cmake

USER nobody:nogroup
RUN --mount=type=bind,from=dl-cmake,target=/build/cache task -d /build/task.d/cmake download
RUN --network=none task -d /build/task.d/cmake bootstrap build install

FROM scratch AS dl-ninja-build
ADD --chmod=444 https://api.github.com/repos/ninja-build/ninja/releases/latest ninja-build-latest.json

FROM base AS ninja-build
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    task -d /build/task.d/deb install-pkgs -- curl libgtest-dev
COPY --from=task ninja-build /build/task.d/ninja-build
COPY --from=cmake --link --chown=root:root /build/install/ /

USER nobody:nogroup
RUN --mount=type=bind,from=dl-ninja-build,target=/build/cache task -d /build/task.d/ninja-build download2
RUN --network=none task -d /build/task.d/ninja-build configure build install

FROM base AS chan-quectel
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    task -d /build/task.d/deb install-pkgs -- git libasound2-dev asterisk-dev

COPY --from=task chan-quectel /build/task.d/chan-quectel
COPY --from=cmake --link --chown=root:root /build/install/ /
COPY --from=ninja-build --link --chown=root:root /build/install /

FROM chan-quectel AS chan-quectel-cc
ARG CC_TARGET
ARG CC_TOOLCHAIN

COPY sources.list /etc/apt/
COPY sources-arm.list /etc/apt/sources.list.d/arm.list
COPY dpkg-buildflags-${CC_TARGET}.env /build/buildflags.env
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    task -d /build/task.d/deb install-pkgs-arch -- qemu-user-static \
    gcc-${CC_TOOLCHAIN} g++-${CC_TOOLCHAIN} binutils-${CC_TOOLCHAIN} \
    libsqlite3-dev:${CC_TARGET} libasound2-dev:${CC_TARGET} asterisk-dev:${CC_TARGET}

FROM chan-quectel AS chan-quectel-cc-ext
ARG CC_TARGET
ARG CC_TOOLCHAIN

COPY sources.list /etc/apt/
COPY sources-arm.list /etc/apt/sources.list.d/arm.list
COPY dpkg-buildflags-${CC_TARGET}.env /build/buildflags.env
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    task -d /build/task.d/deb install-pkgs-arch -- qemu-user-static \
    libsqlite3-dev:${CC_TARGET} libasound2-dev:${CC_TARGET} asterisk-dev:${CC_TARGET}
COPY --from=arm-gnu-toolchain --link --chown=root:root /build/arm-gnu-toolchain/${CC_TOOLCHAIN} /build/arm-gnu-toolchain/${CC_TOOLCHAIN}