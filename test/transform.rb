# Encoding: UTF-8

describe DiceBag::Transform do
  before do
    tree = DiceBag::Parser.new.parse '1d6 e1'
    @ast = DiceBag::Transform.new.apply tree
  end

  describe 'after working on the parsed tree' do
    it 'should return an array' do
      @ast.must_be_instance_of Array
    end

    it 'should have a hash as the first element' do
      @ast.first.must_be_instance_of Hash
    end

    it 'must have a :start key in the first hash element' do
      @ast.first.key?(:start).must_equal true
    end

    it 'must have an :xdx key in the :start hash' do
      @ast.first[:start].key?(:xdx).must_equal true
    end

    it 'must have an :options key in the :start hash' do
      @ast.first[:start].key?(:options).must_equal true
    end
  end
end
