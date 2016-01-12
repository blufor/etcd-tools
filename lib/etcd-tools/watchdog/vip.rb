require 'ipaddr'
require 'etcd-tools/watchdog/init'
require 'etcd-tools/watchdog/threads/icmp'

module EtcdTools
  module Watchdog
    class Vip < EtcdTools::Watchdog::Init

      def run
        if Process.euid != 0
          $stderr.puts 'Must run under root user!'
          exit! 1
        end
        setup 'etcd-vip-watchdog'
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

      # add or remove VIP on interface
      # <IMPLEMENTED>
      def vip_handle!(leader)
        ip = IPAddr.new(@config[:parameters][:vip])
        mask = @config[:parameters][:mask]
        cmd = [ iproute,
                'address',
                '',
                "#{ip}/#{mask}",
                'dev',
                @config[:parameters][:interface],
                'label',
                @config[:parameters][:interface] + '-vip',
                '>/dev/null 2>&1'
              ]
        leader ? cmd[2] = 'add' : cmd[2] = 'delete'
        debug "<shell> #{cmd.join(' ')}"
        if system(cmd.join(' '))
          return true
        else
          return false
        end
      end

      # send gratuitous ARP to the network
      # <IMPLEMENTED>
      def vip_update_arp!
        cmd = [ arping, '-U', '-q',
                '-c', @config[:parameters][:arping_count],
                '-I', @config[:parameters][:interface],
                @config[:parameters][:vip] ]
        debug "<shell> #{cmd.join(' ')}"
        if system(cmd.join(' '))
          return true
        else
          return false
        end
      end

      # check whether VIP is assigned to me
      # <IMPLEMENTED>
      def got_vip?
        cmd = [ iproute,
                'address',
                'show',
                'label',
                "#{@config[:parameters][:interface]}-vip",
                '|',
                'grep',
                '-q',
                "#{@config[:parameters][:interface]}-vip"
              ]
        debug "<shell> #{cmd.join(' ')}"
        if system(cmd.join(' '))
          return true
        else
          return false
        end
      end

      # check reachability of VIP by ICMP echo
      # <--- REWORK
      def vip_alive?(icmp)
        (1..@config[:parameters][:icmp_count]).each { return true if icmp.ping }
        return false
      end

      # check whether the IP is registered anywhere
      #
      def vip_dup?
        cmd_arp = [ arp, '-d', @config[:parameters][:vip], '>/dev/null 2>&1' ]
        cmd_arping = [  arping, '-D', '-q',
                        '-c', @config[:parameters][:arping_count],
                        '-w', @config[:parameters][:arping_wait],
                        '-I', @config[:parameters][:interface],
                        @config[:parameters][:vip] ]
        debug "<shell> #{cmd_arp.join(' ')}"
        system(cmd_arp.join(' '))
        debug "<shell> #{cmd_arping.join(' ')}"
        if system(cmd_arping.join(' '))
          return false
        else
          return true
        end
      end
    end
  end
end
