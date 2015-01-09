require "spec_helper"

describe "Flnt" do
  it "should be a Module" do
    expect(Flnt).to be_a_kind_of Module
  end

  it "should initialize fluentd connection" do
    allow(Flnt).to receive(:initialized?).and_return(false)

    expect(Fluent::Logger::FluentLogger).to receive(:open).with(*Flnt::Configuration())
    Flnt.initialize!
  end

  describe 'on connection ok' do
    before do
      allow(Fluent::Logger::FluentLogger).to receive(:open).with(nil, an_instance_of(Hash))
        .and_return(instance_double("Fluent::Logger::FluentLogger", :post => true))
    end

    it "should initialize fluentd connection just once" do
      allow(Flnt).to receive(:initialized?).and_return(true)

      expect(Fluent::Logger::FluentLogger).not_to receive(:open)
      expect(Flnt).not_to receive(:Configuration)
      Flnt.init_foo
    end

    it "should be able to force to initialize fluentd connection" do
      allow(Flnt).to receive(:initialized?).and_return(true)

      expect(Fluent::Logger::FluentLogger).to receive(:open)
      expect(Flnt).to receive(:Configuration)
      Flnt.initialize!(true)
    end

    it "should return Flnt::Logger tagged with called method name" do
      ret = Flnt.init_foo
      expect(ret.instance_eval { @tag }).to eq "init_foo"

      expect { ret.chain_bar }.not_to raise_error
      expect { ret.respond_to? :foo }.not_to raise_error
      expect { ret.missing_method? }.to raise_error NoMethodError
    end

    it "should create a new logger for each call" do
      logger1 = Flnt.foo_tag
      logger2 = Flnt.foo_tag
      expect(logger1.__id__).not_to eq logger2.__id__
    end

    it "should create a new logger with custom tag" do
      logger = Flnt.tag!("foo.bar.buz")
      expect(logger.instance_eval { @tag }).to eq "foo.bar.buz"
    end
  end
end
