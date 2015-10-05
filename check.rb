["etcd", "erb", "yaml"].each do |lib|
  begin
    print "checking for #{lib} gem... "
    require lib
    puts "OK"
  rescue
    puts "ERROR"
  end
end