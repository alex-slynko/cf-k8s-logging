FROM fluent/fluentd:v1.7.4-debian-1.0

USER root
WORKDIR /home/fluent
ENV PATH /fluentd/vendor/bundle/ruby/2.6.0/bin:$PATH
ENV GEM_PATH /fluentd/vendor/bundle/ruby/2.6.0
ENV GEM_HOME /fluentd/vendor/bundle/ruby/2.6.0
ENV FLUENTD_DISABLE_BUNDLER_INJECTION 1

COPY Gemfile* /fluentd/

RUN buildDeps="sudo make gcc g++ libc-dev libffi-dev" \
     && apt-get update \
     && apt-get upgrade -y \
     && apt-get install \
    -y --no-install-recommends \
     $buildDeps net-tools \
    && apt-get install -y --no-install-recommends git \
    && gem install bundler \
    && bundle config silence_root_warning true \
    && bundle install --gemfile=/fluentd/Gemfile --path=/fluentd/vendor/bundle \
    && SUDO_FORCE_REMOVE=yes \
    apt-get purge -y --auto-remove \
                  -o APT::AutoRemove::RecommendsImportant=false \
                  $buildDeps \
 && rm -rf /var/lib/apt/lists/* \
    && gem sources --clear-all \
    && rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

WORKDIR /fluentd
ENTRYPOINT bundle exec fluentd ${FLUENTD_FLAGS} -c /fluentd/etc/fluentd.conf
