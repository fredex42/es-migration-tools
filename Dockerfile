FROM ruby:2.6-alpine

RUN apk --no-cache add htop jq
COPY es-migration-tools-1.0.0.gem /tmp
RUN gem install /tmp/es-migration-tools-1.0.0.gem
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod a+x /docker-entrypoint.sh
CMD /docker-entrypoint.sh
