# Encoding: UTF-8

describe DiceBag::Transform do
  before do
    tree = DiceBag::Parser.new.parse '1d6 e1 + 2'
    @ast = DiceBag::Transform.new.apply tree
  end

  describe 'after working on the parsed tree' do
    it 'should return an array' do
      @ast.must_be_instance_of Array
    end

    it 'should have an array as the first element' do
      @ast.first.must_be_instance_of Array
    end

    it 'must have a :start op in the first element' do
      @ast.first[0].must_equal :start
    end

    it 'must have an :xdx key in the :start op hash' do
      @ast.first[1].key?(:xdx).must_equal true
    end

    it 'must have an :options key in the :start op hash' do
      @ast.first[1].key?(:options).must_equal true
    end
  end
end
