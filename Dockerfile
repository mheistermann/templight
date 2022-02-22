FROM debian:bookworm-20220125-slim AS builder
RUN apt-get update && apt-get install -y clang-13 git cmake ninja-build

RUN git clone --recursive --depth 1 https://github.com/llvm/llvm-project.git --branch release/14.x /llvm-src

COPY . /llvm-src/clang/tools/templight
RUN echo "add_clang_subdirectory(templight)" >> /llvm-src/clang/tools/CMakeLists.txt

WORKDIR /llvm-build
RUN cmake -GNinja \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_CXX_COMPILER=clang++-13 \
    -DCMAKE_C_COMPILER=clang-13 \
    -DLLVM_ENABLE_PROJECTS="clang" \
    -DLLVM_ENABLE_RUNTIMES="all" \
    -DCMAKE_INSTALL_PREFIX=/opt/llvm \
    /llvm-src/llvm
RUN cmake --build .
RUN cmake --build . --target install

CMD ["/opt/llvm/bin/templight++"]

#FROM alpine:latest
#COPY --from=builder /opt/llvm /opt/llvm
#CMD ["/opt/llvm/bin/clang"]

