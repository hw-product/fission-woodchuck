require 'carnivore-files'

Carnivore.configure do
  paths = Carnivore::Config.get(:fission, :woodchuck, :paths)
  [(paths.is_a?(Hash) ? paths.keys : paths)].flatten.compact.each do |path|
    Carnivore::Source.build(
      :type => :file,
      :args => {:path => path, :name => "woodchuck_#{path.tr('/', '_')}"}
    ).add_callback(:chucking) do |msg|
      # msg -> {:path, :content}
      opts = Carnivore::Config.get(:fission, :woodchuck, :paths, msg[:path]) || {}
      node_name = Carnivore::Config.get(:fission, :woodchuck, :node_name) ||
        %x{dnsdomainname -f}.to_s.strip
      unless(node_name && !node_name.empty?)
        require 'resolv'
        names = Resolv.getnames('127.0.0.1')
        node_name = names.detect{|n|n.include?('.')} || names.first
      end
      entry = msg[:message].merge(:timestamp => Time.now.to_f)
      entry.merge!(:tags => opts[:tags]) if opts[:tags]
      entry.merge!(:source => node_name)
      processor = Carnivore::Config.get(:fission, :woodchuck, :processor)
      payload = Fission::Utils.new_payload(processor, :woodchuck => {:entry => entry})
      if(processor)
        begin
          Fission::Utils.transmit(processor, payload)
        rescue => e
          warn "Failed to ship log line! #{e.class} - #{e} ---- #{msg.inspect}"
        end
      else
        warn "No processor defined for log shipping. Payload not sent! #{payload.inspect}"
      end
    end
  end
end
