# Encoding: UTF-8

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

    it 'must have a sides value in the :xdx hash' do
      _(@parsed.first[:start][:xdx].key?(:sides)).must_equal true
    end
  end
end
