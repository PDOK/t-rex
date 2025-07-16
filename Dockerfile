# build t-rex
FROM ubuntu:plucky as trex-builder
RUN apt-get -y update && apt-get install -y curl make gnupg2 pkg-config openssl libssl-dev clang
ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

COPY ./t-rex-core /t-rex/t-rex-core
COPY ./t-rex-gdal /t-rex/t-rex-gdal
COPY ./t-rex-service /t-rex/t-rex-service
COPY ./t-rex-webserver /t-rex/t-rex-webserver
COPY ./src /t-rex/src
COPY ./Cargo.toml /t-rex/Cargo.toml
COPY ./Cargo.lock /t-rex/Cargo.lock
RUN apt-get update && apt-get install -y libgdal-dev
RUN curl -sSf https://sh.rustup.rs | sh -s -- -y
RUN echo "export PATH=~/.cargo/bin:$PATH" >> ~/.bashrc
#RUN cd /t-rex && cargo test --all
RUN cd /t-rex && cargo build --release

# actual image
FROM ubuntu:noble
ENV TZ Europe/Amsterdam
LABEL MAINTAINER="pdok@kadaster.nl"

RUN apt-get -y update && apt-get install -y gnupg2 software-properties-common
RUN apt-get update && apt-get install -y gdal-bin

COPY --from=trex-builder /t-rex/target/release/t_rex /usr/local/bin

EXPOSE 6767
ENTRYPOINT ["/usr/local/bin/t_rex"]