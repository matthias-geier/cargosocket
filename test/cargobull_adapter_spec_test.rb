class Teacher
  include Cargobull::Service

  def channels(params); ["a", "b"]; end
  def reference(params); "works"; end
  def subscribe(ref, channel); "works"; end
  def unsubscribe(ref, channel); "works"; end
  def error(ref, channel); "works"; end
  def pop(ref, channel, message); "works"; end
  def push(ref, channel, message); "works"; end
end

class Professor
  include Cargobull::Service
end

class Somophore
  include Cargobull::Service

  def channels(params); "works"; end
  def subscribe(ref, channel); nil; end
  def unsubscribe(ref, channel); nil; end
  def error(ref, channel); nil; end
  def pop(ref, channel, message); nil; end
  def push(ref, channel, message); nil; end
end

CargobullAdapter = Cargosocket::StreamAdapters::CargobullAdapter

describe Cargosocket::StreamAdapters::CargobullAdapter do
  before do
    @env = Cargobull.env.get
  end

  describe "channels" do
    it "should forward a symbolized array" do
      assert_equal [:a, :b], CargobullAdapter.channels(@env, 'teacher', {})
    end

    it "should not forward anything but an array" do
      assert_nil CargobullAdapter.channels(@env, 'somophore', {})
    end

    it "should not forward anything when method is missing" do
      assert_nil CargobullAdapter.channels(@env, 'professor', {})
    end
  end

  describe "reference" do
    it "should not forward any value" do
      assert_equal "works", CargobullAdapter.reference(@env, 'student', {})
    end

    it "should not forward anything when method is missing" do
      assert_nil CargobullAdapter.reference(@env, 'professor', {})
    end
  end

  [:subscribe, :unsubscribe, :error].each do |m|
    describe m do
      it "should pass any not-nil value into block and back to scope" do
        blk = ->(v) do
          assert_equal "works", v
          "has worked"
        end
        assert_equal "has worked", CargobullAdapter.send(m, @env, 'student',
          "", "", &blk)
      end

      it "should not do anything on explicit nil return" do
        assert_nil CargobullAdapter.
          send(m, @env, 'somophore', "", ""){ |_| raise "fail" }
      end

      it "should pass error messages, also for missing method" do
        blk = ->(v) do
          assert_equal "Not found", v
          "has worked"
        end
        assert_equal "has worked", CargobullAdapter.
          send(m, @env, 'professor', "", "", &blk)
      end
    end
  end

  [:pop, :push].each do |m|
    describe m do
      it "should pass any not-nil value into block and back to scope" do
        blk = ->(v) do
          assert_equal "works", v
          "has worked"
        end
        assert_equal "has worked", CargobullAdapter.send(m, @env, 'student',
          "", "", "", &blk)
      end

      it "should not do anything on explicit nil return" do
        assert_nil CargobullAdapter.
          send(m, @env, 'somophore', "", "", ""){ |_| raise "fail" }
      end

      it "should pass error messages, also for missing method" do
        blk = ->(v) do
          assert_equal "Not found", v
          "has worked"
        end
        assert_equal "has worked", CargobullAdapter.
          send(m, @env, 'professor', "", "", "", &blk)
      end
    end
  end
end
