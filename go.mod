module github.com/baetyl/baetyl-core

go 1.13

replace (
	github.com/docker/docker => github.com/docker/engine v0.0.0-20191007211215-3e077fc8667a
	github.com/opencontainers/runc => github.com/opencontainers/runc v1.0.0-rc6.0.20190307181833-2b18fe1d885e
)

require (
	github.com/256dpi/gomqtt v0.13.0
	github.com/StackExchange/wmi v0.0.0-20190523213609-cbe669659 // indirect
	github.com/baetyl/baetyl v0.0.0-20200311054409-9c1d1d194316
	github.com/baetyl/baetyl-go v0.1.8
	github.com/docker/go-units v0.4.0
	github.com/golang/mock v1.3.1
	github.com/gorilla/mux v1.7.4 // indirect
	github.com/jinzhu/copier v0.0.0-20190924061706-b57f9002281a
	github.com/shirou/gopsutil v2.20.2+incompatible // indirect
	google.golang.org/grpc v1.25.1
	k8s.io/api v0.0.0-20190620084959-7cf5895f2711
	k8s.io/apimachinery v0.0.0-20190612205821-1799e75a0719
	k8s.io/client-go v12.0.0+incompatible
)
