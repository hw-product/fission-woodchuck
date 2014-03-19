module Fission
  module Woodchuck
    class Chucker < Fission::Callback

      def valid?(*_)
        super do |m|
          retreive(m, :data, :woodchuck) == true ||
          [retreive(m, :data, :woodchuck, :filters)].flatten.compact.empty?
        end
      end

      def execute(message)
        failure_wrap(message) do |payload|
          if(retrieve(payload, :data, :woodchuck) == true)
            payload[:data][:woodchuck] = {
              :filters => Carnivore::Config.get(:fission, :woodchuck, :filters)
            }
            forward(payload)
          else
            store!(payload)
            job_completed('woodchuck', payload, message)
          end
        end
      end

      def store!(payload)
      end

    end
  end
end

Fission.register(:woodchuck, :chucker, Fission::Woodchuck::Chucker)
