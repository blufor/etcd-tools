module EtcdTools
  module Watchdog
    module Threads
      def thread_icmp
        Thread.new do
          debug '<icmp> starting thread...'
          icmp = Net::Ping::ICMP.new(@config[:parameters][:vip])
          while !@exit do
            debug '<icmp> checking state by ping'
            status = vip_alive? icmp
            @semaphore[:icmp].synchronize { @status_icmp = status }
            debug "<icmp> VIP is #{status ? 'alive' : 'down' }"
            sleep @config[:parameters][:icmp_interval]
          end
          info '<icmp> ending thread...'
        end
      end
    end
  end
end
