module EtcdTools
  module EtcdERB
    module Erb
      def result
        super binding
      end

      def value path
        return @etcd.get('/' + path.sub(/^\//, '')).value
      end

      def keys path
        path.sub!(/^\//, '')
        if @etcd.get('/' + path).directory?
          return @etcd.get('/' + path).children.map { |key| key.key }
        else
          return []
        end
      end

      def template
        ARGF.read
      end
    end
  end
end
