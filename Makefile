check:
	@ruby check.rb

install:
	/usr/bin/install -o root -g root -m 755 etcd-erb /bin/
	/usr/bin/install -o root -g root -m 755 yaml2etcd /bin/
	/usr/bin/install -o root -g root -m 755 etcd-ip-watchdog /sbin/
