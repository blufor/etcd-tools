require 'optparse'

module EtcdTools
  module EtcdERB
    module Options
      def optparse
        @options = Hash.new

        @options[:url] = ENV['ETCDCTL_ENDPOINT']
        @options[:url] ||= "http://127.0.0.1:4001"

        OptionParser.new do |opts|
          opts.banner = "Applies variables from ETCD onto ERB template\n\nUsage: #{$0} [OPTIONS] < template.erb > outfile"
          opts.separator ""
          opts.separator "Connection options:"
          opts.on("-u", "--url URL", "URL endpoint of the ETCD service (ETCDCTL_ENDPOINT envvar also applies) [DEFAULT: http://127.0.0.1:4001]") do |param|
            @options[:url] = param
          end
          opts.separator ""
          opts.separator "Common options:"
          opts.on_tail("-h", "--help", "show usage") do |param|
            puts opts
            exit! 0
          end
        end.parse!
      end
    end
  end
end
