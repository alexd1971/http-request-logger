FROM haskell:8.10.7-buster as build

# Copying sources
WORKDIR /tmp/build
COPY    . ./
# Building service
RUN     stack build --system-ghc --copy-bins
# Collecting shared libraries
WORKDIR /root/.local/bin
# RUN ldd ./http-request-log-service
# RUN     mkdir /tmp/lib && for lib in `ldd ./http-request-log-service | grep "=>"| awk '{print $3;}' | egrep -v 'libm.so.6|libc.so.6|ld-linux-x86-64.so.2|libresolv.so.2'`; do cp $lib /tmp/lib/; done

# Building imps docker image
FROM    debian:buster as app
# Copying imps binary
COPY    --from=build /root/.local/bin/http-request-log-service /usr/local/bin/http-request-log-service
# Copying shared library dependencies
# COPY    --from=build /tmp/lib /lib
# Running service
EXPOSE  7777
ENTRYPOINT ["http-request-log-service"]
