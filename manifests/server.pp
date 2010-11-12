class openldap::server {
  include openldap

  package{'openldap-servers':
    ensure => present,
  }
  service{'ldap':
    ensure => running,
    enable => true,
    hasstatus => true,
    require => Package['openldap-servers'],
  }
  file{"/etc/openldap/slapd.conf":
    source => [
      "puppet://$server/modules/site-openldap/$fqdn/slapd.conf",
      "puppet://$server/modules/site-openldap/slapd.conf",
      "puppet://$server/modules/openldap/slapd.conf",
    ],
    require => Package['openldap-servers'],
    notify => Service['ldap'],
    owner => ldap, group => ldap, mode => 0440;
  }
  file{"/var/lib/ldap/DB_CONFIG":
    source => [
      "puppet://$server/modules/site-openldap/$fqdn/DB_CONFIG",
      "puppet://$server/modules/site-openldap/DB_CONFIG",
      "puppet://$server/modules/openldap/DB_CONFIG",
    ],
    require => Package['openldap-servers'],
    notify => Service['ldap'],
    owner => ldap, group => ldap, mode => 0440;
  }
}
