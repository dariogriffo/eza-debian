ARG DEBIAN_DIST=bookworm
FROM debian:$DEBIAN_DIST

ARG DEBIAN_DIST
ARG EZA_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION

RUN apt update && apt install -y wget
RUN mkdir -p /output/usr/bin
RUN mkdir -p /output/usr/share/doc/eza
RUN cd /output/usr/bin && wget https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz && tar -xf eza_x86_64-unknown-linux-gnu.tar.gz && rm -f eza_x86_64-unknown-linux-gnu.tar.gz 
RUN mkdir -p /output/DEBIAN
COPY output/DEBIAN/control /output/DEBIAN/
COPY output/copyright /output/usr/share/doc/eza/
COPY output/changelog.Debian /output/usr/share/doc/eza/
COPY output/README.md /output/usr/share/doc/eza/

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/usr/share/doc/eza/changelog.Debian
RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/eza/changelog.Debian
RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/control
RUN sed -i "s/EZA_VERSION/$EZA_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control

RUN dpkg-deb --build /output /eza_${FULL_VERSION}.deb
