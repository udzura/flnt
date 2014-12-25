require "spec_helper"

describe "Flnt::Logger" do
  before do
    allow(Fluent::Logger::FluentLogger).to receive(:open).with(nil, an_instance_of(Hash))
      .and_return(instance_double("Fluent::Logger::FluentLogger", :post => true))
  end

  def tag_of(flnt_logger)
    return flnt_logger.instance_eval { @tag }
  end

  it "should chain the method call appending a tag" do
    expect(tag_of Flnt.tag!("sample.foo")).to eq "sample.foo"
  end

  it "should have cached some logging methods" do
    logger = Flnt.tag("sample")
    %i(debug info warn error fatal).each do |name|
      expect(logger).to respond_to name
    end
  end

  it "should be mocked by rspec successfully" do
    logger = Flnt.tag("sample")
    expect(logger).to receive(:info).with(instance_of(String))
    logger.info "test"
  end

  it "should not cache tag called with args" do
    logger = Flnt.tag("sample.foo")
    expect(Fluent::Logger).not_to receive(:post).with("sample.foo.info.info", {message: "Hello multi times"})
    expect(Fluent::Logger).to receive(:post).with("sample.foo.info", {message: "Hello multi times"}).thrice

    3.times do
      logger.info "Hello multi times"
    end
  end

  describe "should send messages when called with arg" do
    context "when String" do
      specify do
        expect(Fluent::Logger).to receive(:post).with("sample.info", {message: "Hello Info"})
        Flnt.tag("sample").info "Hello Info"
      end
    end

    context "when Hash" do
      specify do
        expect(Fluent::Logger).to receive(:post).with("sample.info", {info1: "Info", info2: 1234})
        Flnt.tag("sample").info({info1: "Info", info2: 1234})
      end
    end

    context "when Error" do
      let(:error) { StandardError.new "Error Info" }

      specify do
        expect(Fluent::Logger).to receive(:post)
          .with("sample.info", {error_class: StandardError, message: "Error Info"})
        Flnt.tag("sample").info(error)
      end
    end

    context "else" do
      let(:obj) { Object.new }

      specify do
        expect(Fluent::Logger).to receive(:post).with("sample.info", {info: obj})
        Flnt.tag("sample").info(obj)
      end
    end
  end
end
