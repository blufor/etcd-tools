desc "Build gem"
task :build do
  sh 'gem build -V etcd-tools.gemspec'
end

desc "Install local gem"
task :install do
  sh 'gem install etcd-tools-*.gem'
end

desc "Clean build gems"
task :clean do
  sh 'rm -f *.gem'
end

task :default => [:clean, :build, :install]
