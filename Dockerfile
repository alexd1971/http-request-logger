FROM haskell:8.10.7-buster as build

# Copying sources
WORKDIR /tmp/build
COPY    . ./
# Building service
RUN     stack build --system-ghc --copy-bins

# Building imps docker image
FROM    debian:buster-slim as app
# Copying binary
COPY    --from=build /root/.local/bin/http-request-log-service /usr/local/bin/http-request-log-service
# Running service
EXPOSE  7777
ENTRYPOINT ["http-request-log-service"]
