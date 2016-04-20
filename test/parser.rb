# Encoding: UTF-8

describe DiceBag::Parser do
  before do
    @parsed = DiceBag::Parser.new.parse '1d6 + 2'
  end

  describe 'after parsing' do
    it 'should return an array' do
      @parsed.must_be_instance_of Array
    end

    it 'should have a hash as the first element' do
      @parsed.first.must_be_instance_of Hash
    end

    it 'must have a :start key in the first hash element' do
      @parsed.first.key?(:start).must_equal true
    end

    it 'must have an :xdx key in the :start hash' do
      @parsed.first[:start].key?(:xdx).must_equal true
    end

    it 'must have an :options key in the :start hash' do
      @parsed.first[:start].key?(:options).must_equal true
    end
  end
end
