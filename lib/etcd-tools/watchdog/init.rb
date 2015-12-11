require 'ipaddr'
require 'timeout'
require 'yaml'
require 'json'
require 'time'
require 'etcd'
require 'etcd-tools/mixins'
require 'etcd-tools/watchdog/config'
require 'etcd-tools/watchdog/logger'
require 'etcd-tools/watchdog/helpers'
require 'etcd-tools/watchdog/etcd'
require 'etcd-tools/watchdog/threads/etcd'

module EtcdTools
  module Watchdog
    class Init

      include EtcdTools::Watchdog::Config
      include EtcdTools::Watchdog::Logger
      include EtcdTools::Watchdog::Helpers
      include EtcdTools::Watchdog::Etcd
      include EtcdTools::Watchdog::Threads

      def initialize
        @semaphore = {
          log: Mutex.new,
          etcd: Mutex.new
        }
        @config = { debug: false }
        @config = config
        @exit = false
        # handle various signals
        @exit_sigs = ['INT', 'TERM']
        @exit_sigs.each { |sig| Signal.trap(sig) { @exit = true } }
        Signal.trap('USR1') { @config[:debug] = false }
        Signal.trap('USR2') { @config[:debug] = true }
        Signal.trap('HUP') { @config = config }
        if RUBY_VERSION >= '2.1'
          Process.setproctitle('etcd-vip-watchdog')
        else
          $0 = 'etcd-vip-watchdog'
        end
        # Process.setpriority(Process::PRIO_PROCESS, 0, -20)
        # Process.daemon
      end
    end
  end
end
