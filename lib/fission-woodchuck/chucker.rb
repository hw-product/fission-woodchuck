module Fission
  module Woodchuck
    class Chucker < Fission::Callback

      def setup(*_)
        if(enabled?(:data))
          require 'fission-data/init'
        else
          abort 'Data library is _required_ for woodchuck functionality'
        end
      end

      def valid?(*_)
        super do |m|
          m.get(:data, :woodchuck)
        end
      end

      def execute(message)
        failure_wrap(message) do |payload|
          unless(payload.get(:data, :woodchuck, :filters))
            payload.set(:data, :woodchuck, :filters, Carnivore::Config.get(:fission, :woodchuck, :filters))
          end
          filters = payload.get(:data, :woodchuck, :filters)
          if(filters.empty?)
            store!(payload)
            job_completed(:woodchuck, payload, message)
          else
            destination = filters.shift
            transmit(destination, payload)
            message.confirm!
          end
        end
      end

      def store!(payload)
        Fission::Data::LogEntry.add(
          :log => payload.get(:data, :woodchuck, :entry, :path),
          :entry => payload.get(:data, :woodchuck, :entry, :content),
          :entry_time => payload.get(:data, :woodchuck, :entry, :timestamp),
          :tags => payload.get(:data, :woodchuck, :entry, :tags),
          :source => payload.get(:data, :woodchuck, :entry, :source)
        )
      end

    end
  end
end

Fission.register(:woodchuck, :chucker, Fission::Woodchuck::Chucker)
