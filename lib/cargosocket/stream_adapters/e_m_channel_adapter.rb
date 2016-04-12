
module Cargosocket
  module StreamAdapters
    module EMChannelAdapter
      CHANNELS = {}
      DISPATCHERS = []

      def self.dispatch(to)
        # DISPATCHERS << to
      end

      def self.push(*to, message)
        to.each do |channel|
          if channel.is_a?(Symbol)
            CHANNELS[channel].push(message) if CHANNELS.has_key?(channel)
          else
            # channel.push(message)
          end
        end
      end

      def self.subscribe(*to)
        callback = Proc.new
        return to.reduce({}) do |acc, channel|
          CHANNELS[channel] ||= EM::Channel.new
          acc[channel] = CHANNELS[channel].subscribe(&callback.curry[channel])
          next acc
        end
      end

      def self.unsubscribe(from)
        from.each do |channel, cid|
          yield(channel)
          CHANNELS[channel].unsubscribe(cid)
          if CHANNELS[channel].num_subscribers == DISPATCHERS.count
            CHANNELS.delete(channel)
          end
        end
      end
    end
  end
end
