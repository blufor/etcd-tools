#!/usr/bin/env ruby

require 'etcd-tools/watchdog/init'
require 'etcd-tools/watchdog/haproxy'
require 'etcd-tools/watchdog/threads/haproxy'
require 'etcd-tools/etcd_erb/erb'

module EtcdTools
  module Watchdog
    class HAproxy < EtcdTools::Watchdog::Init

      include EtcdTools::Watchdog::HAproxy

      def run
        while @etcd.watch(@config[:haproxy_cfg])
      end

    end
  end
end
