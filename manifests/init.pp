class golang(
  $installdir = "/usr/local",
  $tempdir    = "/tmp",
  $version    = "1.1.1",
  $user       = "root",
  $gopath  = "/root/go"
) {

  if $user == 'root' {
    $profiledir = '/etc/profile'
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
    creates => "${installdir}/go",
    user    => $user,
    require => File["golang-dir"]
  }

  # Environment variables
  exec { "goroot-profile":
    command => "echo 'export GOROOT=${installdir}/go' >> ${profiledir}/.profile",
    path   => [ '/usr/bin', '/bin' ],
    unless => "grep 'GOROOT' ${profiledir}/.profile",
    user   => $user
  }

  exec { "gowkspc-profile":
    command => "echo 'export GOPATH=${gopath}' >> ${profiledir}/.profile",
    path   => [ '/usr/bin', '/bin' ],
    unless => "grep 'GOPATH' ${profiledir}/.profile"
  }

  exec { "gopath-profile":
    command => "echo 'export PATH=\$PATH:${installdir}/go/bin' >> ${profiledir}/.profile",
    path   => [ '/usr/bin', '/bin' ],
    unless => "grep '${installdir}/go/bin' ${profiledir}/.profile"
  }

  # Vim Syntax highlighting

  # I might use another module for vim at some point...
  ensure_resource('file', '.vim', {'ensure' => 'directory',
                                   'owner' => $user,
                                   'path' => "/home/${user}/.vim"})

  ensure_resource('file', '.vim/syntax', {'ensure' => 'directory',
                                   'owner' => $user,
                                   'path' => "/home/${user}/.vim/syntax",
                                   'require' => "File[.vim]"})

  ensure_resource('file', '.vim/ftdetect', {'ensure' => 'directory',
                                   'owner' => $user,
                                   'path' => "/home/${user}/.vim/ftdetect",
                                   'require' => "File[.vim]"})

  file {'golang-syntax-filetypes':
    path    => "/home/${user}/.vim/ftdetect/go.vim",
    content => 'au BufRead,BufNewFile *.go set filetype=go',
    owner   => $user,
    require => File['.vim/ftdetect']
  }

  file {'golang-syntax':
    path    => "/home/${user}/.vim/syntax/go.vim",
    ensure  => link,
    target  => "${installdir}/go/misc/vim/syntax/go.vim",
    owner   => $user,
    require => File['.vim/syntax']
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

