define golang::get (
  $package = "",
) {
  include golang

  $gopath = $::golang::gopath
  $goroot = "${::golang::installdir}/go/bin/"

  exec { "go-get-${package}":
    command => "go get ${package}",
    path    => [ ${goroot} ],
    creates => "${gopath}/src/${package}",
    user    => "root",
    require => File["golang-dir"]
  }
}
