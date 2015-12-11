module EtcdTools
  module Watchdog
    module Vip
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
        case leader
        when true
          cmd[2] = 'add'
        when false
          cmd[2] = 'delete'
        end
        debug "CMD #{cmd.join(' ')}"
        if system(cmd.join(' '))
          info "IP '#{cmd[2]}' operation done"
        else
          err "IP '#{cmd[2]}' operation failed"
        end
      end

      # send gratuitous ARP to the network
      # <IMPLEMENTED>
      def vip_update_arp!
        cmd = [ arping, '-U', '-q',
                '-c', @config[:parameters][:arping_count],
                '-I', @config[:parameters][:interface],
                @config[:parameters][:vip] ]
        debug "CMD #{cmd.join(' ')}"
        if system(cmd.join(' '))
          info 'gratuitous ARP packet sent'
          return true
        else
          err 'gratuitous ARP packet failed to send'
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
        debug "CMD #{cmd.join(' ')}"
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
        debug "CMD #{cmd_arp.join(' ')}"
        system(cmd_arp.join(' '))
        debug "CMD #{cmd_arping.join(' ')}"
        if system(cmd_arping.join(' '))
          return true
        else
          return false
        end
      end
    end
  end
end
