require 'spec_helper'

describe 'Flnt::TeeableLogger' do
  before do
    allow(Fluent::Logger::FluentLogger).to receive(:open).with(nil, an_instance_of(Hash))
      .and_return(instance_double("Fluent::Logger::FluentLogger", :post => true))
  end

  describe '#tee!' do
    let(:flnt) { Flnt.tag!('cool_log') }
    let(:logger) { Logger.new('/dev/null') }
    let(:new_logger) { flnt.tee!(logger) }

    it 'should set the teed logger' do
      expect(new_logger.teed_loggers.first).to be(logger)
    end

    it 'should tee the log to another logger' do
      expect(Fluent::Logger).to receive(:post).with("cool_log.info", {message: "Hello from Hell"})
      expect(logger).to receive(:info).with("Hello from Hell")

      new_logger.info "Hello from Hell"
    end

    context 'passed just a path' do
      let(:path) { "/tmp/log-#{$$}.log" }
      let(:new_logger) { flnt.tee!(path) }

      it 'should create a logger pointing to the path' do
        expect(new_logger.teed_loggers.first).to be_an_instance_of(Logger)
        logdev = new_logger.teed_loggers.first.instance_eval { @logdev }
        expect(logdev.dev.path).to eq path
      end
    end

    context 'passed just a pathname' do
      let(:path) do
        p = Pathname.new("/tmp/log-#{$$}")
        p.join("app.log")
        p
      end
      let(:new_logger) { flnt.tee!(path) }

      it 'should create a logger pointing to the path' do
        expect(new_logger.teed_loggers.first).to be_an_instance_of(Logger)
        logdev = new_logger.teed_loggers.first.instance_eval { @logdev }
        expect(logdev.dev.path).to eq path.to_s
      end
    end
  end

  # FIXME using fakefs to test real log file
end
