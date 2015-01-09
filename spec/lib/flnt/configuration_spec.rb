require "spec_helper"

describe "Flnt::Configuration" do
  it "should have default values" do
    expect(Flnt::Configuration()).to eq(
      [
        nil,
        {
          host: 'localhost',
          port: 24224,
        }
      ]
    )
  end

  it "should be customized" do
    Flnt::Configuration.configure do |c|
      c.prefix = "foobar"
      c.host = 'fluentd.example.jp'
      c.port = 12345
    end

    expect(Flnt::Configuration()).to eq(
      [
        "foobar",
        {
          host: 'fluentd.example.jp',
          port: 12345,
        }
      ]
    )
  end

  it "should be force to hook Flint.initialize!(true)" do
    allow(Flnt).to receive(:initialized?).and_return(true)
    expect(Fluent::Logger::FluentLogger).to receive(:open)
    expect(Flnt).to receive(:Configuration)

    Flnt::Configuration.configure do |c|
      c.host = 'fluentd.example.jp'
    end
  end

  after do
    Flnt::Configuration.instance_eval do
      @host = nil
      @port = nil
      @prefix = nil
    end
  end
end
