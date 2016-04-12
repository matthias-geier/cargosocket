
module Cargosocket
  module StreamAdapters
    module CargobullAdapter
      def self.if_value(value)
        return if value.last.nil?
        yield(value.last)
      end

      def self.dispatch_to(m, *args)
        Cargobull::Dispatch.send(m, *args)
      end

      def self.channels(cargoenv, path, query)
        r = dispatch_to(:call_no_transform, cargoenv, "CHANNELS", path, query)
        if r.first == 200 && r.last.is_a?(Array) && !r.last.empty?
          r.last.map(&:to_sym)
        end
      end

      def self.reference(cargoenv, path)
        r = dispatch_to(:call_no_transform, cargoenv, "REFERENCE", path)
        if r.first == 200
          r.last
        end
      end

      def self.subscribe(cargoenv, *args)
        if_value(dispatch_to(:call, cargoenv, "SUBSCRIBE", *args), &Proc.new)
      end

      def self.unsubscribe(cargoenv, *args)
        if_value(dispatch_to(:call, cargoenv, "UNSUBSCRIBE", *args), &Proc.new)
      end

      def self.push(cargoenv, *args)
        if_value(dispatch_to(:call, cargoenv, "PUSH", *args), &Proc.new)
      end

      def self.pop(cargoenv, *args)
        if_value(dispatch_to(:call, cargoenv, "POP", *args), &Proc.new)
      end
    end
  end
end
