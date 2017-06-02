FROM gcr.io/google-containers/debian-base-amd64:0.1 

COPY Gemfile /Gemfile

# 1. Install & configure dependencies.
# 2. Install fluentd via ruby.
# 3. Remove build dependencies.
# 4. Cleanup leftover caches & files.
RUN BUILD_DEPS="make gcc g++ libc6-dev ruby-dev" \
    && clean-install $BUILD_DEPS \
                     ca-certificates \
                     libjemalloc1 \
                     liblz4-1 \
                     ruby \
    && echo 'gem: --no-document' >> /etc/gemrc \
    && gem install --file Gemfile \
    && apt-get purge -y --auto-remove \
                     -o APT::AutoRemove::RecommendsImportant=false \
                     $BUILD_DEPS \
    && rm -rf /tmp/* \
              /var/lib/apt/lists/* \
              /usr/lib/ruby/gems/*/cache/*.gem \
              /var/log/* \
              /var/tmp/*

RUN mkdir -p /fluentd/log /fluentd/etc fluentd/plugins

# Copy configuration files
COPY fluent.conf /fluentd/etc/
COPY kubernetes.conf /fluentd/etc/
COPY systemd.conf /fluentd/etc/
COPY output.conf /fluentd/etc/

# Copy exec script
COPY run.sh /run.sh

# Environment variables
ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

# ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"

# Run Fluentd
CMD exec /run.sh -c /fluentd/etc/$FLUENTD_CONF -p /fluentd/plugins $FLUENTD_OPT
