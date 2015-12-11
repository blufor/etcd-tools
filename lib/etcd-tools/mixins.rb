class Hash
  def deep_merge(second)
    merger = proc { |key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
    self.merge(second, &merger)
  end
end

module Etcd
  class Client
    def members
      members = JSON.parse(api_execute(version_prefix + '/members', :get, timeout: 10).body)['members']
      Hash[members.map{|member| [ member['id'], member.tap { |h| h.delete('id') }]}]
    end

    def healthy?
      JSON.parse(api_execute('/health', :get, timeout: 3).body)['health'] == 'true'
    end
  end
end
