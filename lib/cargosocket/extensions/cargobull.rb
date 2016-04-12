
module Cargobull
  def self.streamer(cargoenv=env.get)
    cargoenv[:session] = {}
    cargoenv.freeze
    Cargosocket::Stream.call(cargoenv)
  end

  module Dispatch
    METHOD_MAP.merge!({
      "CHANNELS" => :channels,
      "REFERENCE" => :reference,
      "SUBSCRIBE" => :subscribe,
      "UNSUBSCRIBE" => :unsubscribe,
      "POP" => :pop,
      "PUSH" => :push
    })

    def self.call_no_transform(env, *args)
      dispatch(env, nil, nil, *args)
    end
  end
end

