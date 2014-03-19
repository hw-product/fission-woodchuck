require 'carnivore-file'

Carnivore.configure do
  paths = Carnivore::Config.get(:fission, :woodchuck, :paths)
  [(paths.is_a?(Hash) ? paths.keys : paths)].flatten.compact.each do |path|
    Carnvore::Source.build(
      :type => file,
      :args => {:path => path}
    ).add_callback(:chucking) do |msg|
      # msg -> {:path, :content}
      opts = Carnivore::Config.get(:fission, :woodchuck, :paths, msg[:path])
      msg.merge!(:tags => opts[:tags]) if opts[:tags]
      msg.merge!(:woodchuck => true)
      payload = Fission::Utils.new_payload(:woodchuck, msg)

      Fission::Utils.transmit[:woodchuck].transmit(:woodchuck, payload)
    end
  end
end
