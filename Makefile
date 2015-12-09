default: check install config

check:
	@ruby check.rb

install:
	/usr/bin/install -o root -g root -m 755 bin/etcd-erb /bin/
	/usr/bin/install -o root -g root -m 755 bin/yaml2etcd /bin/
	/usr/bin/install -o root -g root -m 755 bin/etcd-ip-watchdog /sbin/

config:
	/usr/bin/install -o root -g root -m 644 etcd-ip-watchdog.yaml /etc/
