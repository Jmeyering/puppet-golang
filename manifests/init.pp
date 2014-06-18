class golang(
  $installdir = "/usr/local",
  $tempdir    = "/tmp",
  $version    = "1.2.2",
  $user       = "root",
  $gopath  = "/root/go"
) {

  if $user == 'root' {
    $profiledir = '/etc/profile.d'
  } else {
    $profiledir = "/home/${user}"
  }

  file { "golang-dir":
    path => $installdir,
    ensure => "directory",
    owner  => $user
  } 

  file { "golang-gopath":
    path => $gopath,
    ensure => "directory",
    owner  => $user
  } 

  download_file { "go${version}":
    name   => "go${version}.linux-amd64.tar.gz",
    uri    => "http://golang.org/dl",
    cwd    => $tempdir,
    # install as root
    user   => $user,
    before => Exec['extract'],
  }

  exec { "extract":
    command => "tar -C ${installdir} -xzf ${tempdir}/go${version}.linux-amd64.tar.gz",
    path    => [ '/usr/bin', '/bin' ],
    creates => "${installdir}/go",
    user    => $user,
    require => File["golang-dir"]
  }

  exec { "gopath-profile":
    command => "echo 'export PATH=\$PATH:${installdir}/go/bin' >> ${profiledir}/.profile ; echo 'export GOPATH=\$HOME/go';echo 'export PATH=\$PATH:\$GOPATH/bin'",
    path   => [ '/usr/bin', '/bin' ],
    unless => "grep '${installdir}/go/bin' ${profiledir}/.profile"
  }
}

define download_file(
  $uri,
  $name="",
  $cwd="",
  $creates="",
  $user=""
) {
  exec { $name:
    command => "wget ${uri}/${name}",
    path => [ '/usr/bin', '/bin' ],
    cwd => $cwd,
    creates => "${cwd}/${name}",
    unless => "test -f ${cwd}/${name}",
    user => $user,
  }
}

