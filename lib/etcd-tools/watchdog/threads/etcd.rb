module EtcdTools
  module Watchdog
    module Threads
      def thread_etcd
        Thread.new do
          debug '<etcd> starting thread...'
          etcd = etcd_connect!
          while !@exit do
            debug '<etcd> checking etcd state'
            status = leader? etcd
            @semaphore[:etcd].synchronize { @status_etcd = status }
            debug "<etcd> i am #{status ? 'the leader' : 'not a leader' }"
            sleep @config[:parameters][:etcd_interval]
          end
          info '<etcd> ending thread...'
        end
      end
    end
  end
end
