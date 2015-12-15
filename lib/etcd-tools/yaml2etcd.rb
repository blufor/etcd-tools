require 'yaml'
require 'etcd'
require_relative 'etcd-tools/yaml2etcd/options'
require_relative 'etcd-tools/yaml2etcd/import'

module EtcdTools
  module Cli
    class Yaml2Etcd

      include EtcdTools::Yaml2Etcd::Options
      include EtcdTools::Yaml2Etcd::Import

      def initialize
        self.optparse
        @etcd = self.class.connect(@options[:url], @options[:verbose])
        @hash = self.class.read_yaml
        import_structure @hash, @options[:root_path]
      end

      class << self
        def read_yaml
          begin
            return YAML.load(ARGF.read)
          rescue
            $stderr.puts "Couldn't parse YAML"
            exit! 1
          end
        end

        def connect (url, verbose=false)
          (host, port) = url.gsub(/^https?:\/\//, '').gsub(/\/$/, '').split(':')
          etcd = Etcd.client(host: host, port: port)
          begin
            etcd.version
            puts "Connected to ETCD on #{host}:#{port}" if verbose
            return etcd
          rescue Exception => e
            $stderr.puts "Couldn't connect to etcd at #{host}:#{port}"
            $stderr.puts e.message
            exit! 1
          end
        end
      end
    end
  end
end
