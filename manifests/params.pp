class postgresql::params {
  $locale = 'en_US.UTF-8'

  $ssl = false
  $ssl_ca_file = undef # the default is 'root.crt'
  $ssl_cert_file = undef # the default is 'server.crt'
  $ssl_crl_file = undef # the default is 'root.crl'
  $ssl_key_file = undef # the default is 'server.key'



  case $::operatingsystem {
    /(Ubuntu|Debian)/ : {
      $version = '9.1'
      $client_package = 'postgresql-client'
      $server_package = "postgresql-${version}"
      $listen_address = 'localhost'
      $postgresql_confdir = "/etc/postgresql/$version/main"
      $postgresql_conf = "${postgresql_confdir}/postgresql.conf"
      $pg_hba_conf = "${postgresql_confdir}/pg_hba.conf"
      $pg_ident_conf = "${postgresql_confdir}/pg_ident.conf"
      $service_name  = 'postgresql'
      $socket_dir = '/var/run/postgresql'    
      $provider = 'debian'
      $port = 5432
    }
    /(RedHat|CentOS)/ : {
      $version = '9.1'
      $client_package = 'postgresql'
      $server_package = 'postgresql91-server'
      $listen_address = 'localhost'
      $postgresql_confdir = "/var/lib/pgsql/$version/data"
      $postgresql_conf = "${postgresql_confdir}/postgresql.conf"
      $pg_hba_conf = "${postgresql_confdir}/pg_hba.conf"
      $pg_ident_conf = "${postgresql_confdir}/pg_ident.conf"
      $service_name = "postgresql-${version}"
      $socket_dir = '/tmp'
      $provider = 'redhat'
      $port = 5432
    }
    default           : {
      fail("Unsupported platform: ${::operatingsystem}")
    }
  }
}
