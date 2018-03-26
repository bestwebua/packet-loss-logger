# You must run this test case
# with root privileges on UNIX systems.

require_relative '../packet_loss_logger'

describe PacketLossLogger do

  it 'instance of class PacketLossLogger' do
    expect(subject).to be_an_instance_of(PacketLossLogger)
  end

  describe '#params_not_valid?' do
    it 'should raise an ArgumentError error if argument not passed' do
      expect { subject.params_valid? }.to raise_error(ArgumentError)
    end

    it 'should return true if passed argument valid' do
      expect(subject.params_valid?(["google.com", "1000", "1m"])).to eq(true)
    end

    it 'should return false if passed not valid argument' do
      expect(subject.params_valid?('not valid argument')).to eq(false)
    end
  end

  describe '#runtime_calculation' do
    it 'should parse and transform to_i if input in sec' do
      expect(subject.runtime_calculation(['', '', '1s'])).to eq(1)
    end

    it 'should parse and convert input from min to sec and return as integer' do
      expect(subject.runtime_calculation(['', '', '1m'])).to eq(60)
    end

    it 'should parse and convert input from hours to sec and return as integer' do
      expect(subject.runtime_calculation(['', '', '1h'])).to eq(3600)
    end

    it 'should parse and convert input from days to sec and return as integer' do
      expect(subject.runtime_calculation(['', '', '1d'])).to eq(86400)
    end
  end

  describe '#set_logger_settings' do
    it 'should raise an ArgumentError error if argument not passed' do
      expect { subject.set_logger_settings }.to raise_error(ArgumentError)
    end

    it 'should return the number of instance variables' do
      expect(subject.set_logger_settings(['host.com', '1000'], 60).instance_variables.size).to eq(7)
    end
  end

  it '#set_ping_settings' do
    expect(subject.set_ping_settings('localhost', 500).superclass).to eq(Net::Ping)
  end

  it '#set_save_settings' do
    expect(subject.set_save_settings.class).to eq(File)
  end

  describe '#ping_log_inform' do
    logger = PacketLossLogger.new
    logger.set_save_settings

      it 'just puts if ping return true' do
        logger.set_logger_settings(['localhost', '1000'], 1)
        logger.set_ping_settings(logger.host, logger.packet_size)
        logger.ping_log_inform
        expect(logger.the_worst_time).to be > 0
      end

      it 'counting of fails and immediate save to the log if ping return false' do
        logger.set_logger_settings(['fakehost', '1000'], 1)
        logger.set_ping_settings(logger.host, logger.packet_size)
        logger.ping_log_inform
        (expect(logger.total_fails).to be > 0) && (expect(!File.zero?(logger.log)).to eq(true))
        File.delete(logger.log)
      end
  end

  describe '#save_results' do
    location = File.expand_path('../.', File.dirname(__FILE__))
    file = File.new("#{location}/log.txt", 'a+')

      it 'should return true if data has been stored' do
        expect(subject.save_results(file)).to eq(true)
        File.delete(file)
      end
  end

  it '#informer' do
    file = File.new('fakefile', 'a+')
    expect(subject.informer(file)).to eq(false)
    File.delete(file)
  end

end