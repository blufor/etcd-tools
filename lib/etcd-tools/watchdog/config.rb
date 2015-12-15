module EtcdTools
  module Watchdog
    module Config
      private
      def default_config
        { debug: false,
          parameters: { interface: 'eth0',
                        vip: '192.168.0.168',
                        mask: '255.255.255.0',
                        interval: 1,
                        etcd_endpoint: 'http://127.0.0.1:4001',
                        etcd_interval: 1,
                        etcd_timeout: 5,
                        icmp_count: 2,
                        icmp_interval: 1,
                        arping_count: 1,
                        arping_wait: 1 },
          commands: { arping: `which arping`.chomp,
                      iproute: `which ip`.chomp,
                      arp: `which arp`.chomp } }
      end

      def config
        cfg = default_config
        if File.exist? '/etc/etcd-watchdog.yaml'
          cfg = cfg.deep_merge YAML.load_file('/etc/etcd-watchdog.yaml')
          puts 'loaded config from /etc/etcd-watchdog.yaml'
        elsif File.exist? './etcd-watchdog.yaml'
          cfg = cfg.deep_merge YAML.load_file('./etcd-watchdog.yaml')
          puts 'loaded config from ./etcd-watchdog.yaml'
        else
          puts 'no config file loaded, using defaults'
        end
        cfg
      end
    end
  end
end
