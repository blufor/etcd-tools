require 'yaml'
require 'erb'
require 'etcd'
require 'etcd-tools/etcd_erb/options'
require 'etcd-tools/etcd_erb/erb'

module EtcdTools
  class EtcdERB < ERB

    include EtcdTools::EtcdERB::Options
    include EtcdTools::EtcdERB::Erb

    attr_reader :etcd

    def initialize
      self.optparse
      @etcd = self.class.connect(@options[:url])
      super self.class.template
      puts self.result
    end

    class << self
      def connect (url)
        (host, port) = url.gsub(/^https?:\/\//, '').gsub(/\/$/, '').split(':')
        etcd = Etcd.client(host: host, port: port)
        begin
          etcd.version
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
