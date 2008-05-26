# manifests/shorewall.pp

class openldap::shorewall::client {
    shorewall::rule { 
        'me-net-ldapserver_tcp':
            source          => '$FW',
            destination     => 'all',
            proto           => 'tcp',
            destinationport => 'ldap,ldaps',
            order           => 320,
            action          => 'ACCEPT';
         'me-net-ldapserver_udp':
            source          => '$FW',
            destination     => 'all',
            proto           => 'udp',
            destinationport => 'ldap,ldaps',
            order           => 320,
            action          => 'ACCEPT';
    }
}
