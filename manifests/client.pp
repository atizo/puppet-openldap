class openldap::client(
  $ldap_server,
  $base,
  $use_cacert_ca = false,
  $sudoers_base = false
) {
  include openldap
  include nscd

  if $use_cacert_ca {
    include cacert
    file{'/etc/openldap/cacerts/cacert.pem':
      ensure => '/etc/pki/tls/certs/cacert-ca-class-1.crt',
      owner => root, group => 0, mode => 0644;
    }
  } else {
    file{'/etc/openldap/cacerts/cacert.pem':
      source => "puppet://$server/modules/site-openldap/cacerts/cacert.pem",
      owner => root, group => 0, mode => 0644;
    }
  }

  if defined(Service['nscd']) {
    File['/etc/openldap/cacerts/cacert.pem'] {
      notify => [
        Service['nscd'],
        Exec['create_hash_link'],
      ],
    }
  } else {
    File['/etc/openldap/cacerts/cacert.pem'] {
      notify => Exec['create_hash_link'],
    }
  }
  
  # clear all links, make hash link for the cert
  exec{'create_hash_link':
    command => 'cd /etc/openldap/cacerts && find -type l -exec rm {} \; && ln -s cacert.pem `openssl x509 -noout -hash < /etc/openldap/cacerts/cacert.pem`.0',
    refreshonly => true,
  }

  # this command is used to generate the following files
  # authconfig --useshadow --enableshadow --usemd5 --enablemd5 --enableldap \
  # --enableldaptls --enableldapauth --ldapserver=$ldap_server --ldapbasedn=$base_dn \
  # --enablelocauthorize --kickstart
  file{'/etc/pam.d/system-auth-ac':
    source => [
      "puppet://$server/modules/site-openldap/$fqdn/system-auth-ac",
      "puppet://$server/modules/site-openldap/system-auth-ac",
      "puppet://$server/modules/openldap/system-auth-ac",
    ],
    require => Package['openldap'],
    owner => root, group => 0, mode => 0644;
  }
  file{'/etc/pam.d/system-auth':
    ensure => "/etc/pam.d/system-auth-ac",
    require => [
      File['/etc/pam.d/system-auth-ac'],
      Package['openldap'],
    ],
  }
  file{"/etc/ldap.conf":
    content => template("site-openldap/client/ldap.conf.erb"),
    require => File["/etc/pam.d/system-auth-ac"],
    owner => root, group => 0, mode => 0644;
  }
  file{"/etc/openldap/ldap.conf":
    content => template("site-openldap/client/ldap.conf.erb"),
    require => Package['openldap'],
    owner => root, group => 0, mode => 0644;
  }
  file{"/etc/nsswitch.conf":
    source => [
      "puppet://$server/modules/site-openldap/$fqdn/nsswitch.conf",
      "puppet://$server/modules/site-openldap/nsswitch.conf",
      "puppet://$server/modules/openldap/nsswitch.conf",
    ],
    require => File["/etc/pam.d/system-auth-ac"],
    notify => Service['nscd'],
    owner => root, group => 0, mode => 0644;
  }
}
