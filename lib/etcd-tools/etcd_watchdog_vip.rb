#!/usr/bin/env ruby

require 'net/ping'
require 'etcd-tools/watchdog/init'
require 'etcd-tools/watchdog/vip'
require 'etcd-tools/watchdog/threads/icmp'

module EtcdTools
  class VipWatchdog < EtcdTools::Watchdog::Init

    include EtcdTools::Watchdog::Vip

    def run
      if Process.euid != 0
        $stderr.puts 'Must run under root user!'
        exit! 1
      end
      setup
      @semaphore = {
        log: Mutex.new,
        etcd: Mutex.new,
        icmp: Mutex.new
      }
      @thread = { icmp: thread_icmp, etcd: thread_etcd }
      @status_etcd = false
      @status_icmp = false
      @thread.each_value(&:run)
      sleep @config[:parameters][:interval]
      first_cycle = true
      while !@exit do
        status_etcd = status_icmp = false # FIXME: introduce CVs...
        @semaphore[:icmp].synchronize { status_icmp = @status_icmp }
        @semaphore[:etcd].synchronize { status_etcd = @status_etcd }
        if status_etcd
          if got_vip?
            debug '<main> i am the leader with VIP, that is OK'
          else
            info '<main> i am the leader without VIP, checking whether it is free'
            if status_icmp
              info '<main> VIP is still up! (ICMP)'
              # FIXME: notify by sensu client socket
            else
              info '<main> VIP is unreachable by ICMP, checking for duplicates on L2'
              if vip_dup?
                info '<main> VIP is still assigned! (ARP)'
                # FIXME: notify by sensu client socket
              else
                info '<main> VIP is free, assigning'
                vip_handle! status_etcd
                info '<main> updating other hosts about change'
                vip_update_arp!
              end
            end
          end
        else
          if got_vip?
            info '<main> i got VIP and should not, removing'
            vip_handle! status_etcd
            info '<main> updating other hosts about change'
            vip_update_arp!
          else
            debug '<main> i am not a leader and i do not have the VIP, that is OK'
          end
        end
        sleep @config[:parameters][:interval]
        if first_cycle
          @semaphore[:icmp].synchronize { status_icmp = @status_icmp }
          @semaphore[:etcd].synchronize { status_etcd = @status_etcd }
          info "<main> i #{status_etcd ? 'AM' : 'am NOT'} the leader"
          info "<main> i #{got_vip? ? 'DO' : 'do NOT'} have the VIP"
          info "<main> i #{status_icmp ? 'CAN' : 'CANNOT'} see the VIP"
        end
        first_cycle = false
      end
      info '<main> terminated!'
      if got_vip?
        info '<main> removing VIP'
        vip_handle! false
        vip_update_arp!
      end
      info '<main> stopping threads...'
      @thread.each_value(&:join)
      info '<main> exiting...'
      exit 0
    end
  end
end
