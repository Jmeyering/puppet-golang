define golang::get {
  include golang

  $gopath = $::golang::gopath
  $goroot = "${::golang::installdir}/go/bin/"
  $user = $::golang::user

  exec { "go-get-${name}":
    environment => ["GOPATH=${gopath}"],
    command     => "go get ${name}",
    path        => [ $goroot, "/usr/bin", "/bin" ],
    creates     => "${gopath}/src/${name}",
    user        => $user,
    require     => Exec['golang-extract'],
  }
}
