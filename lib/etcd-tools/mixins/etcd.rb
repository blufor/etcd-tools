require 'etcd'
require 'etcd/client'

module Etcd
  class Client

    attr_reader :cluster

    def initialize(opts = {})
      @cluster = opts[:cluster] || [{ host: '127.0.0.1', port: 2379 }]
      if !opts[:host].nil? || !opts[:port].nil?
        @cluster = [{ host: opts[:host], port: opts[:port] }]
      end
      @config = Config.new
      @config.read_timeout = opts[:read_timeout] || 10
      @config.use_ssl = opts[:use_ssl] || false
      @config.verify_mode = opts.key?(:verify_mode) ? opts[:verify_mode] : OpenSSL::SSL::VERIFY_PEER
      @config.user_name = opts[:user_name] || nil
      @config.password = opts[:password] || nil
      @config.ca_file = opts.key?(:ca_file) ? opts[:ca_file] : nil
      @config.ssl_cert = opts.key?(:ssl_cert) ? opts[:ssl_cert] : nil
      @config.ssl_key = opts.key?(:ssl_key) ? opts[:ssl_key] : nil
      yield @config if block_given?
    end

    def api_execute(path, method, options = {})
      params = options[:params]
      case  method
      when :get
        req = build_http_request(Net::HTTP::Get, path, params)
      when :post
        req = build_http_request(Net::HTTP::Post, path, nil, params)
      when :put
        req = build_http_request(Net::HTTP::Put, path, nil, params)
      when :delete
        req = build_http_request(Net::HTTP::Delete, path, params)
      else
        fail "Unknown http action: #{method}"
      end
      req.basic_auth(user_name, password) if [user_name, password].all?
      cluster_http_request(req, options)
    end

    def cluster_http_request(req, options={})
      cluster.each do |member|
        http = build_http_object(member[:host], member[:port], options)
        begin
          Log.debug("Invoking: '#{req.class}' against '#{member[:host]}:#{member[:port]}' -> '#{req.path}'")
          res = http.request(req)
          Log.debug("Response code: #{res.code}")
          Log.debug("Response body: #{res.body}")
          return process_http_request(res)
        rescue Timeout::Error
          Log.debug("Timeout")
          next
        end
        fail
      end
    end

    def build_http_object(host, port, options={})
      http = Net::HTTP.new(host, port)
      http.read_timeout = options[:timeout] || read_timeout
      http.open_timeout = options[:timeout] || read_timeout # <- can't modify Config constant with specific option
      setup_https(http)
      http
    end

    def set_hash(hash, path = '')
      hash.each do |key, value|
        path = "" if path == '/'
        etcd_key = path + '/' + key.to_s
        if value.class == Hash
          set_hash(value, etcd_key)
        elsif value.class == Array
          set(etcd_key, value: value.to_json)
        else
          set(etcd_key, value: value)
        end
      end
    rescue Exception => e
      raise e #fixme
    end

    def get_hash(path = '')
      h = {}
      get(path).children.each do |child|
        if get(child.key).directory?
          h[child.key.split('/').last.to_s] = get_hash child.key
        else
          value = JSON.parse(child.value) rescue value = child.value
          h[child.key.split('/').last.to_s] = value
        end
      end
      return Hash[h.sort]
    rescue Exception => e
      raise e
      puts e.backtrace
    end

    def members
      members = JSON.parse(api_execute(version_prefix + '/members', :get).body)['members']
      Hash[members.map{|member| [ member['id'], member.tap { |h| h.delete('id') }]}]
    end

    def healthy?
      JSON.parse(api_execute('/health', :get).body)['health'] == 'true'
    rescue
      false
    end
  end
end
