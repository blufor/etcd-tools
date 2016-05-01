require 'optparse'
require 'etcd-tools/etcd'
require 'etcd-tools/erb'

module EtcdTools
  module Cli
    class EtcdERB
      include EtcdTools::Etcd

      def optparse
        @options = Hash.new

        @options[:url] = ENV['ETCDCTL_ENDPOINT']
        @options[:url] ||= "http://127.0.0.1:2379"

        OptionParser.new do |opts|
          opts.banner = "Applies variables from ETCD onto ERB template\n\nUsage: #{$0} [OPTIONS] < template.erb > outfile"
          opts.separator ""
          opts.separator "Connection options:"
          opts.on("-u", "--url URL", "URL endpoint of the ETCD service (ETCDCTL_ENDPOINT envvar also applies) [DEFAULT: http://127.0.0.1:2379]") do |param|
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

      def initialize
        self.optparse

        begin
          @etcd = etcd_connect @options[:url]
        rescue Etcd::ClusterConnectError
          $stderr.puts "Failed to connect to ETCD cluster"
          exit! 1
        end

        begin
          template = EtcdTools::Erb.new @etcd, ARGF.read
          puts template.result
        rescue Exception => e
          $stderr.puts "Failed to parse ERB template!"
          $stderr.puts e.message
          exit! 1
        end
      end
    end
  end
end
