#!/bin/sh

# add our svn location to the httpd config
cat <<EOF > /usr/local/apache2/conf/extra/vife.conf
LoadModule	dav_module           modules/mod_dav.so
LoadModule	dav_svn_module       /usr/lib/apache2/modules/mod_dav_svn.so
LoadModule	authz_svn_module     /usr/lib/apache2/modules/mod_authz_svn.so
LoadModule  auth_openidc_module  /usr/lib/apache2/modules/mod_auth_openidc.so

# rewriting Destination because we're behind an SSL terminating reverse proxy
# see http://www.dscentral.in/2013/04/04/502-bad-gateway-svn-copy-reverse-proxy/  
RequestHeader edit Destination ^https: http: early

OIDCProviderMetadataURL ${OIDCProviderMetadataURL}
OIDCClientID ${OIDCClientID}
OIDCClientSecret ${OIDCClientSecret}

# OIDCRedirectURI is a vanity URL that must point to a path protected by this module but must NOT point to any content
OIDCRedirectURI ${OIDCRedirectURI}
OIDCCryptoPassphrase <password>

# maps the preferred_username claim to the REMOTE_USER environment variable
OIDCRemoteUserClaim preferred_username

# need to set OIDCXForwardedHeaders since we're behind an SSL terminating proxy
OIDCXForwardedHeaders X-Forwarded-Host

<Location />
    DAV svn
    SVNParentPath /var/svn
    SVNListParentPath On

    AuthType openid-connect
    Require valid-user
</Location>
EOF

# run the command given in the Dockerfile at CMD 
exec "$@"
