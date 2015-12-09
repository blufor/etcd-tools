["etcd", "erb", "optparse", "yaml"].each do |lib|
  begin
    print "checking for #{lib} gem... "
    require lib
    puts "OK"
  rescue
    puts "ERROR"
    exit 1
  end
end