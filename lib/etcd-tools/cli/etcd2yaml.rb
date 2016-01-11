require 'optparse'
require 'yaml'
require 'etcd-tools/etcd'

module EtcdTools
  module Cli
    class Etcd2Yaml
      include EtcdTools::Etcd

      def optparse
        @options = Hash.new

        @options[:url] = ENV['ETCDCTL_ENDPOINT']
        @options[:url] ||= "http://127.0.0.1:4001"
        @options[:root_path] = "/config"

        OptionParser.new do |opts|
          opts.banner = "Parses ETCD tree into structured YAML\n\nUsage: #{$0} [OPTIONS]"
          opts.separator ""
          opts.separator "Connection options:"
          opts.on("-u", "--url HOST", "URL endpoint of the ETCD service (ETCDCTL_ENDPOINT envvar also applies) [DEFAULT: http://127.0.0.1:4001]") do |param|
            @options[:url] = param
          end
          opts.separator ""
          opts.separator "Common options:"
          opts.on("-r", "--root-path PATH", "root PATH of ETCD tree to extract the data from [DEFAULT: /config]") do |param|
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

      def initialize
        self.optparse

        begin
          @etcd = etcd_connect @options[:url]
        rescue Exception => e
          $stderr.puts "Failed to connect to ETCD!"
          $stderr.puts e.message
          exit! 1
        end

        begin
          hash = etcd2hash @etcd, @options[:root_path]
          puts YAML.dump hash
        rescue Exception => e
          $stderr.puts "Import failed"
          $stderr.puts e.message
          exit! 1
        end
      end

    end
  end
end
