# rubocop:disable Metrics/BlockLength
describe DiceBag::Parser do
  describe 'after parsing with a standard xdx form' do
    before do
      @parsed = DiceBag::Parser.new.parse '1d6 + 2'
    end

    it 'should return an array' do
      _(@parsed).must_be_instance_of Array
    end

    it 'should have a hash as the first element' do
      _(@parsed.first).must_be_instance_of Hash
    end

    it 'must have a :start key in the first hash element' do
      _(@parsed.first.key?(:start)).must_equal true
    end

    it 'must have an :xdx key in the :start hash' do
      _(@parsed.first[:start].key?(:xdx)).must_equal true
    end

    it 'must have an :options key in the :start hash' do
      _(@parsed.first[:start].key?(:options)).must_equal true
    end

    it 'should have a hash as the second element' do
      _(@parsed[1]).must_be_instance_of Hash
    end

    it 'should have a :op key in the second hash' do
      _(@parsed[1].key?(:op)).must_equal true
    end

    it 'must have the :op key string value of +' do
      _(@parsed[1][:op]).must_equal '+'
    end

    it 'should have a :value key in the second hash' do
      _(@parsed[1].key?(:value)).must_equal true
    end

    it 'must have the :value key be a string value of 2' do
      _(@parsed[1][:value]).must_equal '2'
    end
  end

  describe 'after parsing with an optional missing number of dice' do
    before do
      @parsed = DiceBag::Parser.new.parse 'd6 + 2'
    end

    it 'should return an array' do
      _(@parsed).must_be_instance_of Array
    end

    it 'should have a hash as the first element' do
      _(@parsed.first).must_be_instance_of Hash
    end

    it 'must have a :start key in the first hash element' do
      _(@parsed.first.key?(:start)).must_equal true
    end

    it 'must have an :options key in the :start hash' do
      _(@parsed.first[:start].key?(:options)).must_equal true
    end

    it 'must have an :xdx key in the :start hash' do
      _(@parsed.first[:start].key?(:xdx)).must_equal true
    end

    it 'must have a count value in the :xdx hash' do
      _(@parsed.first[:start][:xdx].key?(:count)).must_equal true
    end

    it 'must have a count value of nil' do
      _(@parsed.first[:start][:xdx][:count]).must_be_nil
    end

    it 'must have a sides value in the :xdx hash' do
      _(@parsed.first[:start][:xdx].key?(:sides)).must_equal true
    end

    it 'must have a sides string value of 6' do
      _(@parsed.first[:start][:xdx][:sides]).must_equal '6'
    end
  end
end
# rubocop:enable Metrics/BlockLength
