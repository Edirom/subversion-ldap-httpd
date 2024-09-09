FROM httpd:2.4
LABEL maintainer="Peter Stadler for the ViFE"

# For information about these parameters see 
# https://github.com/OpenIDC/mod_auth_openidc
ARG OIDCProviderMetadataURL
ARG OIDCClientID
ARG OIDCClientSecret
ARG OIDCRedirectURI
ARG OIDCCryptoPassphrase

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl subversion ca-certificates libapache2-mod-auth-openidc && \
    rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /my-docker-entrypoint.sh
RUN chmod 755 /my-docker-entrypoint.sh

WORKDIR /usr/local/apache2
RUN echo "Include conf/extra/vife.conf" >> conf/httpd.conf

VOLUME ["/var/svn"]
ENTRYPOINT ["/my-docker-entrypoint.sh"]
CMD ["httpd-foreground"]
