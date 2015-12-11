#!/usr/bin/env ruby

require 'net/ping'

module EtcdTools
  module Watchdog
    class HAproxy < EtcdTools::Watchdog::Init

      include EtcdTools::Watchdog::HAproxy

      def run
        @thread = {
          etcd: thread_etcd
        }
        @status_etcd = false
      end

    end
  end
end
