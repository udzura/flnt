require "spec_helper"

describe "Flnt::Logger" do
  before do
    allow(Fluent::Logger::FluentLogger).to receive(:open).with(nil, an_instance_of(Hash))
  end

  def tag_of(flnt_logger)
    return flnt_logger.instance_eval { @tag }
  end

  it "should chain the method call appending a tag" do
    expect(tag_of Flnt.sample.foo).to eq "sample.foo"
    expect(tag_of Flnt._sample._foo2).to eq "_sample._foo2"
    expect(tag_of Flnt.sample.foo.bar).to eq "sample.foo.bar"
  end

  it "should raise when chained with ! or ? methods" do
    expect {
      Flnt.sample.warn!
    }.to raise_error NoMethodError

    expect {
      Flnt.sample.info?
    }.to raise_error NoMethodError
  end

  describe "should send messages when called with arg" do
    context "when String" do
      specify do
        expect(Fluent::Logger).to receive(:post).with("sample.info", {message: "Hello Info"})
        Flnt.sample.info "Hello Info"
      end
    end

    context "when Hash" do
      specify do
        expect(Fluent::Logger).to receive(:post).with("sample.info", {info1: "Info", info2: 1234})
        Flnt.sample.info({info1: "Info", info2: 1234})
      end
    end

    context "when Error" do
      let(:error) { StandardError.new "Error Info" }

      specify do
        expect(Fluent::Logger).to receive(:post)
          .with("sample.info", {error_class: StandardError, message: "Error Info"})
        Flnt.sample.info(error)
      end
    end

    context "else" do
      let(:obj) { Object.new }

      specify do
        expect(Fluent::Logger).to receive(:post).with("sample.info", {info: obj})
        Flnt.sample.info(obj)
      end
    end
  end
end
