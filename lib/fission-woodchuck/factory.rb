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
      msg[:message].merge!(:tags => opts[:tags]) if opts[:tags]
      payload = Fission::Utils.new_payload(:woodchuck, msg[:message])
      processor = Carnivore::Config.get(:fission, :woodchuck, :processor)
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
