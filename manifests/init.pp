class golang(
  $installdir = "/usr/local",
  $tempdir    = "/tmp",
  $version    = "1.1.1",
  $user       = "root",
  $workspace  = "${user}/go"
) {

  if $user == 'root' {
    $profiledir = '/root'
  } else {
    $profiledir = "/home/${user}"
  }

  file { "golang-dir":
    path => $installdir,
    ensure => "directory",
    owner  => $user
  } 

  file { "golang-workspace":
    path => $workspace,
    ensure => "directory",
    owner  => $user
  } 

  download_file { "go1.1.1":
    uri    => "http://go.googlecode.com/files/go${version}.linux-amd64.tar.gz",
    name   => "go${version}.linux-amd64.tar.gz",
    cwd    => $tempdir,
    # install as root
    user   => $user
  } ->
  exec { "extract":
    command => "tar -C ${installdir} -xzf ${tempdir}/go${version}.linux-amd64.tar.gz",
    path    => [ '/usr/bin', '/bin' ],
    creates => "/usr/local/go",
    user    => $user,
    require => File["golang-dir"]
  }
  
  exec { "goroot-profile":
    command => "echo 'export GOROOT=${installdir}/go' >> ${profiledir}/.profile",
    path   => [ '/usr/bin', '/bin' ],
    unless => "grep 'GOROOT' ${profiledir}/.profile",
    user   => $user
  }

  exec { "gowkspc-profile":
    command => "echo 'export GOPATH=${workspace}' >> ${profiledir}/.profile",
    path   => [ '/usr/bin', '/bin' ],
    unless => "grep 'GOPATH' ${profiledir}/.profile"
  }

  exec { "gopath-profile":
    command => "echo 'export PATH=\$PATH:${installdir}/go/bin' >> ${profiledir}/.profile",
    path   => [ '/usr/bin', '/bin' ],
    unless => "grep '${installdir}/go/bin' ${profiledir}/.profile"
  }

}

define download_file(
  $uri,
  $name,
  $cwd="",
  $creates="",
  $user=""
) {
  exec { $name:
    command => "curl -kL ${uri} -o '${name}'",
    path => [ '/usr/bin', '/bin' ],
    cwd => $cwd,
    creates => "${cwd}/${name}",
    user => $user,
  }
}

