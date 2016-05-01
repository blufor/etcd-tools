require 'etcd'
require 'etcd-tools/mixins'

module EtcdTools

  module Etcd
    def etcd_connect(url, timeout = 2)
      url.split(',').each do |u|
        (host, port) = u.gsub(/^https?:\/\//, '').gsub(/\/$/, '').split(':')
        etcd = ::Etcd.client(host: host, port: port, read_timeout: timeout)
        next unless etcd.healthy?
        return etcd
      end
      raise Etcd::ClusterConnectError
    end
  end
end
