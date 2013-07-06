# puppet-golang #

A puppet module for installing the go runtime

## Usage ##
To install for a particular user:

    class { 'golang':
      user => 'mc',
      installdir => "/home/mc/projects/golang",
      gopath  => "/home/mc/projects/go"
    }

Or to install to the system profile
    
    include golang

This will set the gopath to /root/go, which will prevent non system users from using tools like go get, and is probably not terribly useful.
