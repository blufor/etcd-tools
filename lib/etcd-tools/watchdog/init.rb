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
        @config = { debug: false }
        @config = config
        @exit = false
        @exit_sigs = ['INT', 'TERM']
        @exit_sigs.each { |sig| Signal.trap(sig) { @exit = true } }
        Signal.trap('USR1') { @config[:debug] = false }
        Signal.trap('USR2') { @config[:debug] = true }
        Signal.trap('HUP')  { @config = config }
      end

      def setup(proc_name, nice = -20)
        if RUBY_VERSION >= '2.1'
          Process.setproctitle(proc_name)
        else
          $0 = proc_name
        end
        Process.setpriority(Process::PRIO_PROCESS, 0, nice)
        # TODO: Process.daemon ...
      end
    end
  end
end
