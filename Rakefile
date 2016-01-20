desc 'Help'
task :help do
  sh 'rake -T'
end

desc 'Build gem'
task :build do
  sh 'gem build -V etcd-tools.gemspec'
end

desc 'Install local gem'
task :install do
  sh 'gem install etcd-tools-*.gem'
end

desc 'Clean build gems'
task :clean do
  sh 'rm -f *.gem'
end

desc 'Push new gem'
task :push do
  sh 'gem push etcd-tools-*.gem'
end

desc 'Clean, build & install'
task all: [:clean, :build, :install]

task default: :help
