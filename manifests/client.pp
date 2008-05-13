# manifests/client.pp

class openldap::client inherits openldap {
    file{"/etc/openldap/cacerts/cacert.pem":
        source => "puppet://$server/files/openldap/cacerts/cacert.pem",
        owner => root, group => 0, mode => 0644;
    }

    file{"/etc/pam.d/system-auth":
        ensure => "/etc/pam.d/system-auth-ac",
        require => [ File["/etc/pam.d/system-auth-ac"], Package[openldap] ],
    }

    # this command is used to geneare the following files
    # authconfig --useshadow --enableshadow --usemd5 --enablemd5 --enableldap \
    # --enableldaptls --enableldapauth --ldapserver=$ldapserver --ldapbasedn=dc=puzzle,dc=itc \
    # --enablelocauthorize --kickstart
    file{"/etc/pam.d/system-auth-ac":
        source => [ "puppet://$server/files/openldap/${fqdn}/system-auth-ac",
                    "puppet://$server/files/openldap/${operatingsystem}/system-auth-ac",
                    "puppet://$server/files/openldap/system-auth-ac",
                    "puppet://$server/openldap/${operatingsystem}/system-auth-ac",
                    "puppet://$server/openldap/system-auth-ac" ],
        require => Package[openldap],
        owner => root, group => 0, mode => 0644;
    }

    # set variables

    $real_ldap_base_dn = $ldap_base_dn ? {
        '' => 'dc=puzzle,dc=itc',
        default => $ldap_base_dn
    }

    $real_ldap_sudoers = $ldap_sudoers ? {
        '' => 'false',
        default => $ldap_sudoers,
    }

    $real_ldap_server = $ldap_server ? {
        '' => 'proximai.rz.puzzle.ch',
        default => $ldap_server
    }

    file{"/etc/ldap.conf":
        content => template("openldap/${operatingsystem}/ldap.conf.erb"),
        owner => root, group => 0, mode => 0644;
    }

    file{"/etc/nsswitch.conf":
        source => [ "puppet://$server/files/openldap/${fqdn}/nsswitch.conf",
                    "puppet://$server/files/openldap/${operatingsystem}/nsswitch.conf",
                    "puppet://$server/files/openldap/nsswitch.conf",
                    "puppet://$server/openldap/${operatingsystem}/nsswitch.conf",
                    "puppet://$server/openldap/nsswitch.conf" ],
        require => Package[openldap],
        owner => root, group => 0, mode => 0644;
    }
}
