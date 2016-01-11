require 'etcd'
require 'etcd-tools/mixins'

module EtcdTools
  module Etcd
    def etcd_connect (url)
      (host, port) = url.gsub(/^https?:\/\//, '').gsub(/\/$/, '').split(':')
      etcd = ::Etcd.client(host: host, port: port)
      begin
        etcd.version
        return etcd
      rescue Exception => e
        raise e #fixme
      end
    end

    def hash2etcd (etcd, hash, path="")
      begin
        hash.each do |key, value|
          etcd_key = path + "/" + key.to_s
          case value
          when Hash
            hash2etcd(value, etcd_key)
          else
            etcd.set(etcd_key, value: value)
          end
        end
      rescue Exception => e
        raise e #fixme
      end
    end

    def etcd2hash (etcd, path="")
      begin
        hash = Hash.new
        etcd.get(path).children.each do |child|
          if etcd.get(child.key).directory?
            hash[child.key.split('/').last.to_sym] = etcd2hash etcd, child.key
          else
            hash[child.key.split('/').last.to_sym] = child.value
          end
        end
      rescue
        return nil
      end
      return hash.sort.to_h
    end

  end
end
