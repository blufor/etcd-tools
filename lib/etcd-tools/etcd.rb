require 'etcd'
require 'etcd-tools/mixins'

module EtcdTools
  class ClusterConnectError < Exception
  end

  module Etcd
    def etcd_connect(url, timeout = 2)
      url = url.split(',')
      url.each do |u|
        (host, port) = u.gsub(/^https?:\/\//, '').gsub(/\/$/, '').split(':')
        etcd = ::Etcd.client(host: host, port: port, read_timeout: timeout)
        next unless etcd.healthy?
        return etcd
      end
      raise EtcdTools::ClusterConnectError
    end
  end
end
