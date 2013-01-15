class postgresql::server (
  $server_package = $postgresql::params::server_package,
  $locale = $postgresql::params::locale,
  $version = $postgresql::params::version,
  $listen = $postgresql::params::listen_address,
  $port = $postgresql::params::port,
  $ssl = $postgresql::params::ssl,
  $ssl_ca_file   = $postgresql::params::ssl_ca_file,
  $ssl_cert_file = $postgresql::params::ssl_cert_file,
  $ssl_crl_file  = $postgresql::params::ssl_crl_file,
  $ssl_key_file  = $postgresql::params::ssl_key_file,
  $preacl = [],
  $acl = [],
  $manage_service = true
) inherits postgresql::params {

  file { 'postgresql-server-policyrc.d':
    ensure => present,
    name   => '/usr/sbin/policy-rc.d',
    owner  => root,
    group  => root,
    mode   => '0755',
    source => "puppet:///modules/${module_name}/postgresql-policyrc.d"
  }

  if ($manage_service) {
    exec { "postgresql-initdb-$version":
      path    => '/usr/bin:/usr/sbin:/bin',
      unless  => "test -d ${postgresql::params::postgresql_confdir}/",
      command => "/sbin/service ${service_name} initdb",
    }

    file { 'run-dir':
      ensure => 'directory',
      path => '/var/run/postgresql',
      owner => 'postgres',
      group => 'postgres',
    }

    service { "postgresql-system-$version":
      name        => $postgresql::params::service_name,
      enable      => true,
      ensure      => running,
      hasstatus   => false,
      hasrestart  => true,
      provider    => $postgresql::params::provider,
      require     => [Exec["postgresql-initdb-$version"],File['run-dir']],
      subscribe   => Package["postgresql-server-$version"],
    }

    $notify_service = Service["postgresql-system-$version"]
    $package_require = []

  } else {

    $notify_service = []
    $package_require = File['postgresql-server-policyrc.d']

  }

  package { "postgresql-server-$version":
    name    => $server_package,
    ensure  => present,
    require => $package_require,
  }

  file { "postgresql-server-config-$version":
    name    => $postgresql::params::postgresql_conf,
    ensure  => present,
    content => template('postgresql/postgresql.conf.erb'),
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0644',
    require => Package["postgresql-server-$version"],
    notify  => $notify_service,
  }

  file { "postgresql-server-hba-config-$version":
    name    => $postgresql::params::pg_hba_conf,
    ensure  => present,
    content => template('postgresql/pg_hba.conf.erb'),
    owner   => 'postgres',
    group   => 'postgres',
    mode    => '0640',
    require => Package["postgresql-server-$version"],
    notify  => $notify_service,
  }

}
