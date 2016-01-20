require 'erb'
require 'etcd-tools/etcd'

module EtcdTools
  class Erb < ::ERB

    include EtcdTools::Etcd

    attr_reader :etcd

    def initialize (etcd, template, requires=['yaml', 'json', 'time'])
      @safe_level = nil
      requires.each do |r|
        require r
      end
      @etcd = etcd
      compiler = ::ERB::Compiler.new('-')
      set_eoutvar(compiler, '_erbout')
      @src, @enc = *compiler.compile(template)
      @filename = nil
    end

    def result
      super binding
    end

    def value path
      @etcd.get('/' + path.sub(/^\//, '')).value
    end

    def keys path
      path.sub!(/^\//, '')
      if @etcd.get('/' + path).directory?
        return @etcd.get('/' + path).children.map { |key| key.key }
      else
        return []
      end
    end

    def hash path
      etcd2hash @etcd, path
    rescue
      {}
    end

    def members
      Hash[ @etcd.members.map { |id, md| [ id, md.merge({ 'ip' => md['clientURLs'].first.sub(/https?:\/\//, '').sub(/:[0-9]+/, '') }) ] } ]
    end

  end
end
