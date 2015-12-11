module EtcdTools
  module Watchdog
    module Etcd
      # connect to ETCD
      def etcd_connect!
        (host, port) = @config[:parameters][:etcd_endpoint].gsub(/^https?:\/\//, '').gsub(/\/$/, '').split(':')
        etcd = ::Etcd.client(host: host, port: port)
        begin
          versions = JSON.parse(etcd.version)
          info "<etcd> conncted to ETCD at #{@config[:parameters][:etcd_endpoint]}"
          info "<etcd> server version: #{versions['etcdserver']}"
          info "<etcd> cluster version: #{versions['etcdcluster']}"
          info "<etcd> healthy: #{etcd.healthy?}"
          return etcd
        rescue Exception => e
          err "<etcd> couldn't connect to etcd at #{host}:#{port}"
          err "<etcd> #{e.message}"
          @exit = true
        end
      end

      # is my ETCD the leader?
      # <IMPLEMENTED>
      def leader?(etcd)
        etcd.stats(:self)['id'] == etcd.stats(:self)['leaderInfo']['leader']
      end

    end
  end
end
