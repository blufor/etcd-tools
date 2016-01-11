require 'etcd-tools/watchdog/init'
# require 'etcd-tools/watchdogthreads/haproxy'
require 'etcd-tools/erb'

module EtcdTools
  module Watchdog
    class HAproxy < EtcdTools::Watchdog::Init

      def run
        while @etcd.watch(@config[:haproxy_cfg]) do

        end
      end

      def generate_config
      end

      def reload_haproxy
      end

    end
  end
end
