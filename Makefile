check:
	@ruby check.rb

install:
	/usr/bin/install -o root -g root -m 755 etcdimport /bin/
	/usr/bin/install -o root -g root -m 755 etcdtmpl /bin/