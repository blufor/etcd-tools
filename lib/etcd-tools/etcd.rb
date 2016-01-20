require 'etcd'
require 'etcd-tools/mixins'

module EtcdTools
  module Etcd
    def etcd_connect(url)
      (host, port) = url.gsub(/^https?:\/\//, '').gsub(/\/$/, '').split(':')
      etcd = ::Etcd.client(host: host, port: port)
      begin
        etcd.version
        return etcd
      rescue Exception => e
        raise e #fixme
      end
    end

    def hash2etcd(etcd, hash, path = '')
      hash.each do |key, value|
        path = "" if path == '/'
        etcd_key = path + '/' + key.to_s
        if value.class == Hash
          hash2etcd(etcd, value, etcd_key)
        else
          etcd.set(etcd_key, value: value)
        end
      end
    rescue Exception => e
      raise e #fixme
    end

    def etcd2hash(etcd, path = '')
      h = {}
      etcd.get(path).children.each do |child|
        if etcd.get(child.key).directory?
          h[child.key.split('/').last.to_s] = etcd2hash etcd, child.key
        else
          h[child.key.split('/').last.to_s] = child.value
        end
      end
      return Hash[h.sort]
    rescue Exception => e
      return nil
    end
  end
end
