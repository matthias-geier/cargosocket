class Student
  include Cargobull::Service

  def channels(params); "works"; end
  def reference(params); "works"; end
  def subscribe(ref, channel); "works"; end
  def unsubscribe(ref, channel); "works"; end
  def error(ref, channel); "works"; end
  def pop(ref, channel, message); "works"; end
  def push(ref, channel, message); "works"; end
end

describe Cargobull::Dispatch do
  before do
    @env = Cargobull.env.get
  end

  describe "method translation" do
    it "should extend the restful methods by websocket methods" do
      ["CHANNELS", "REFERENCE", "SUBSCRIBE", "UNSUBSCRIBE", "PUSH", "POP"].
        each do |m|

        assert Cargobull::Dispatch.translate_method_call(@env, m).is_a?(Symbol)
      end
    end
  end

  [:call, :call_no_transform].each do |m|
    describe m do
      before do
        next if m == :call
        @env.merge!({ transform_in: ->(*_){ raise "fail" },
          transform_out: ->(*_){ raise "fail" } })
      end

      it "should call the channels with one param" do
        assert_equal [200, { "Content-Type" => "text/plain" }, "works"],
          Cargobull::Dispatch.send(m, @env, "CHANNELS", 'student', {})
      end

      it "should call the reference" do
        assert_equal [200, { "Content-Type" => "text/plain" }, "works"],
          Cargobull::Dispatch.send(m, @env, "REFERENCE", 'student', {})
      end

      it "should call the subscribe with ref and channel" do
        assert_equal [200, { "Content-Type" => "text/plain" }, "works"],
          Cargobull::Dispatch.send(m, @env, "SUBSCRIBE", 'student', "", "")
      end

      it "should call the unsubscribe with ref and channel" do
        assert_equal [200, { "Content-Type" => "text/plain" }, "works"],
          Cargobull::Dispatch.send(m, @env, "UNSUBSCRIBE", 'student', "", "")
      end

      it "should call the error with ref and channel" do
        assert_equal [200, { "Content-Type" => "text/plain" }, "works"],
          Cargobull::Dispatch.send(m, @env, "ERROR", 'student', "", "")
      end

      it "should call the push with ref, channel and message" do
        assert_equal [200, { "Content-Type" => "text/plain" }, "works"],
          Cargobull::Dispatch.send(m, @env, "PUSH", 'student', "", "", "")
      end

      it "should call the pop with ref, channel and message" do
        assert_equal [200, { "Content-Type" => "text/plain" }, "works"],
          Cargobull::Dispatch.send(m, @env, "POP", 'student', "", "", "")
      end
    end
  end
end
