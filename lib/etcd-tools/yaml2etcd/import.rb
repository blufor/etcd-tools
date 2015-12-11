module EtcdTools
  module Yaml2Etcd
    module Methods
      def import_structure (hash, path="")
        begin
          hash.each do |k, v|
            etcd_key = path + "/" + k.to_s
            case v
            when Hash
              import_structure(v, etcd_key)
            else
              @etcd.set(etcd_key, value: v)
              puts("SET: " + etcd_key + ": " + v.to_json) if @options[:verbose]
            end
          end
        rescue Exception => e
          $stderr.puts "Configuration import failed"
          $stderr.puts e.message
          exit! 1
        end
      end
    end
  end
