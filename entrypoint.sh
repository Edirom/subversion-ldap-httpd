#!/bin/sh

# add our svn location to the httpd config
cat <<EOF > /usr/local/apache2/conf/extra/vife.conf
LoadModule	dav_module           modules/mod_dav.so
LoadModule	dav_svn_module       /usr/lib/apache2/modules/mod_dav_svn.so
LoadModule	authz_svn_module     /usr/lib/apache2/modules/mod_authz_svn.so
LoadModule	ldap_module          modules/mod_ldap.so
LoadModule	authnz_ldap_module   modules/mod_authnz_ldap.so
<Location />
    DAV svn
    SVNParentPath /var/svn
    SVNListParentPath On
    AuthName "ViFE Subversion Repositories: Login mit Nutzernamen und Passwort" 
    AuthBasicProvider ldap
    AuthType Basic
    AuthLDAPGroupAttribute member
    AuthLDAPGroupAttributeIsDN on
    AuthLDAPURL ${AuthLDAPURL}
    AuthLDAPBindDN "${AuthLDAPBindDN}" 
    AuthLDAPBindPassword "${AuthLDAPBindPassword}" 
    Require ldap-group CN=${RequireLDAPGroup},CN=Users,DC=muwi,DC=hfm-detmold,DC=de
    # read-only access
    <limit GET PROPFIND OPTIONS HEAD>
        Require ldap-user redmine
    </limit>
</Location>
EOF

# run the command given in the Dockerfile at CMD 
exec "$@"