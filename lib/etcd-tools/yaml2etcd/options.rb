require 'optparse'

module EtcdTools
  module Yaml2Etcd
    module Options
      def optparse
        @options = Hash.new

        @options[:url] = ENV['ETCDCTL_ENDPOINT']
        @options[:url] ||= "http://127.0.0.1:4001"
        @options[:root_path] = "/config"


        OptionParser.new do |opts|
          opts.banner = "Reads YAML file and imports the data into ETCD\n\nUsage: #{$0} [OPTIONS] < config.yaml"
          opts.separator ""
          opts.separator "Connection options:"
          opts.on("-u", "--url HOST", "URL endpoint of the ETCD service (ETCDCTL_ENDPOINT envvar also applies) [DEFAULT: http://127.0.0.1:4001]") do |param|
            @options[:url] = param
          end
          opts.separator ""
          opts.separator "Common options:"
          opts.on("-r", "--root-path PATH", "root PATH of ETCD tree to inject the data [DEFAULT: /config]") do |param|
            @options[:root_path] = param
          end
          opts.on("-v", "--verbose", "run verbosely") do |param|
            @options[:verbose] = param
          end
          opts.on_tail("-h", "--help", "show usage") do |param|
            puts opts;
            exit! 0
          end
        end.parse!
      end
    end
  end
end
