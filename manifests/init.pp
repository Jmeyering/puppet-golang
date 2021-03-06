class golang(
  $version    = "",
  $platform    = "linux-amd64",
  $installdir = "/usr/local",
  $tempdir    = "/tmp",
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
    filename   => "go${version}.${platform}.tar.gz",
    uri    => "http://golang.org/dl",
    cwd    => $tempdir,
    user   => $user,
    before => Exec['golang-extract'],
  }

  exec { "golang-extract":
    command => "tar -C ${installdir} -xzf ${tempdir}/go${version}.${platform}.tar.gz",
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
  $filename="",
  $cwd="",
  $creates="",
  $user=""
) {
  exec { $filename:
    command => "wget ${uri}/${filename}",
    path => [ '/usr/bin', '/bin' ],
    cwd => $cwd,
    creates => "${cwd}/${filename}",
    unless => "test -f ${cwd}/${filename}",
    user => $user,
  }
}

