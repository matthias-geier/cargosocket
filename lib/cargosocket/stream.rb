
module Cargosocket
  module Stream
    WS_OPT_KEYS = %w{host port debug secure secure_proxy tls_options
      close_timeout outbound_limit}.map(&:to_sym)

    def self.call(cargoenv)
      raise "requires stream adapter" unless cargoenv[:adapter]

      EM.run do
        ws_config = WS_OPT_KEYS.reduce({}) do |acc, key|
          acc[key] = cargoenv[key] if cargoenv.has_key?(key)
          next acc
        end
        EM::WebSocket.run(ws_config){ |ws| config_socket(cargoenv, ws) }
      end
    end

    def self.config_socket(cargoenv, ws)
      ws.onopen do |w|
        path = w.path.sub(/^\//, '')
        periodic_ping(cargoenv, ws)
        EM.add_timer(0.5){ setup_connection(cargoenv, ws, path, w.query) }
      end
    end

    def self.periodic_ping(cargoenv, ws)
      EM.add_periodic_timer(cargoenv[:ping_timer] || 5){ ws.ping }
    end

    def self.setup_connection(cargoenv, ws, path, query)
      cb_adapter = StreamAdapters::CargobullAdapter

      channels = cb_adapter.channels(cargoenv, path, query)
      ref = cb_adapter.reference(cargoenv, path, query)
      if channels && ref
        state = cargoenv[:adapter].subscribe(*channels) do |channel, message|
          cb_adapter.pop(cargoenv, path, ref, channel, message,
            &ws.method(:send))
        end

        state.keys.each do |channel|
          cb_adapter.subscribe(cargoenv, path, ref, channel) do |v|
            cargoenv[:adapter].push(channel, v)
          end
        end

        ws.onmessage do |message|
          state.keys.each do |channel|
            cb_adapter.push(cargoenv, path, ref, channel,
              message.strip){ |v| cargoenv[:adapter].push(channel, v) }
          end
        end

        ws.onerror do |error|
          cargoenv[:adapter].unsubscribe(state) do |channel|
            cb_adapter.error(cargoenv, path, ref, channel) do |v|
              cargoenv[:adapter].push(channel, v)
            end
          end
        end

        ws.onclose do
          cargoenv[:adapter].unsubscribe(state) do |channel|
            cb_adapter.unsubscribe(cargoenv, path, ref, channel) do |v|
              cargoenv[:adapter].push(channel, v)
            end
          end
        end
      else
        ws.close(3001, channels.inspect || ref.to_s || "unknown")
      end
    end
  end
end
