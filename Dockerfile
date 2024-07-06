FROM nickblah/lua:5.2.4-luarocks-alpine3.19

RUN apk add build-base bsd-compat-headers curl-dev m4 && \
    mkdir -p /opt/milua

WORKDIR /opt/milua

COPY milua-*.rockspec .
RUN luarocks make --only-deps

COPY . /opt/milua
RUN luarocks make

WORKDIR /

RUN rm -r /opt/milua

LABEL author.name="MiguelMJ"
LABEL author.email="miguelmjvg@gmail.com"
