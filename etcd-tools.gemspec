Gem::Specification.new do |s|
  s.name                  = 'etcd-tools'
  s.version               = '0.4.3'
  s.date                  = Time.now.strftime('%Y-%m-%d')
  s.summary               = "ETCD tools"
  s.description           = "A set of handful command-line utils for ETCD + lib extensions"
  s.authors               = ["Radek 'blufor' Slavicinsky"]
  s.email                 = 'radek.slavicinsky@gmail.com'
  s.files                 = Dir['lib/**/*.rb']
  s.executables           = Dir['bin/*'].map(){ |f| f.split('/').last }
  s.homepage              = 'https://github.com/blufor/etcd-tools'
  s.license               = 'GPLv2'
  s.required_ruby_version = '>= 1.9.3'
  s.add_runtime_dependency 'etcd', '~> 0.3', '>= 0.3.0'
end
