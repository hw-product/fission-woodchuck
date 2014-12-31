module Fission
  module Woodchuck
    # Default handler for payloads generated by factory
    class Chucker < Fission::Callback

      # Initialize the data store which is required
      def setup(*_)
        if(enabled?(:data))
          require 'fission-data/init'
          require 'time'
          interval = (Carnivore::Config.get(:fission, :woodchuck, :prune, :interval) || 86400) + (rand * 1000)
          prune_before = Carnivore::Config.get(:fission, :woodchuck, :prune, :entry_lifetime) || 86400
          every(interval) do
            Fission::Data::Models::LogEntry.where(
              'created_at < :prune_before',
              :prune_before => Time.now - prune_before
            ).destroy
          end
        else
          abort 'Data library is _required_ for woodchuck functionality'
        end
      end

      # Validity of message
      #
      # @param message [Carnivore::Message]
      # @return [Truthy, Falsey]
      def valid?(message)
        super do |m|
          m.get(:data, :woodchuck)
        end
      end

      # Handle payload generated by the factory. Will
      # add configuration defined filters to payload
      # and forward until filters have been exhausted.
      # Then payload will be stored in data store.
      #
      # @param message [Carnivore::Message]
      def execute(message)
        failure_wrap(message) do |payload|
          unless(payload.get(:data, :woodchuck, :filters))
            defined_filters = Carnivore::Config.get(:fission, :woodchuck, :filters) || []
            payload.set(:data, :woodchuck, :filters, defined_filters)
          end
          filters = payload.get(:data, :woodchuck, :filters)
          if(filters.empty?)
            store!(payload)
            job_completed(:woodchuck, payload, message)
          else
            destination = filters.shift
            payload.set(:data, :woodchuck, :filters, filters)
            transmit(destination, payload)
            message.confirm!
          end
        end
      end

      # Store the file contents within the payload in the data store
      #
      # @param payload [Hash]
      def store!(payload)
        Fission::Data::Models::LogEntry.add(
          :log => payload.get(:data, :woodchuck, :entry, :path),
          :entry => payload.get(:data, :woodchuck, :entry, :content),
          :timestamp => payload.get(:data, :woodchuck, :entry, :timestamp),
          :tags => payload.get(:data, :woodchuck, :entry, :tags),
          :source => payload.get(:data, :woodchuck, :entry, :source),
          :account_id => payload.fetch(:data, :account, :id, 1)
        )
      end

    end
  end
end

Fission.register(:woodchuck, :chucker, Fission::Woodchuck::Chucker)
