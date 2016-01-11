require 'timeout'
require 'json'
require 'time'
require 'etcd-tools/mixins'
require 'etcd-tools/watchdog/util/config'
require 'etcd-tools/watchdog/util/logger'
require 'etcd-tools/watchdog/util/helpers'
require 'etcd-tools/watchdog/util/etcd'
require 'etcd-tools/watchdog/threads/etcd'

module EtcdTools
  module Watchdog
    class Init

      include EtcdTools::Watchdog::Util::Config
      include EtcdTools::Watchdog::Util::Logger
      include EtcdTools::Watchdog::Util::Helpers
      include EtcdTools::Watchdog::Util::Etcd
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
