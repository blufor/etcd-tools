require 'optparse'
require 'yaml'
require 'etcd-tools/etcd'

module EtcdTools
  module Cli
    class Yaml2Etcd
      include EtcdTools::Etcd

      def optparse
        @options = Hash.new

        @options[:url] = ENV['ETCDCTL_ENDPOINT']
        @options[:url] ||= "http://127.0.0.1:2379"
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
          opts.on_tail("-h", "--help", "show usage") do |param|
            puts opts;
            exit! 0
          end
        end.parse!
      end

      def initialize
        self.optparse

        begin
          @hash = YAML.load ARGF.read
        rescue Exception => e
          $stderr.puts "Failed to parse YAML!"
          $stderr.puts e.message
          exit! 1
        end

        begin
          @etcd = etcd_connect @options[:url]
        rescue EtcdTools::ClusterConnectError
          $stderr.puts "Failed to connect to ETCD cluster"
          exit! 1
        end

        begin
          @etcd.set_hash(@hash, @options[:root_path])
        rescue Exception => e
          $stderr.puts "Import failed"
          $stderr.puts e.message
          exit! 1
        end
        puts "OK"
      end

    end
  end
end
