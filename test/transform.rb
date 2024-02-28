# Encoding: UTF-8

describe DiceBag::Transform do
  describe 'with a standard dice form' do
    before do
      tree = DiceBag::Parser.new.parse '2d6 e1 + 2'
      @ast = DiceBag::Transform.new.apply tree
    end

    it 'should return an array' do
      _(@ast).must_be_instance_of Array
    end

    it 'should have an array as the first element' do
      _(@ast.first).must_be_instance_of Array
    end

    it 'must have a :start op in the first element' do
      _(@ast.first[0]).must_equal :start
    end

    it 'must have an :xdx key in the :start op hash' do
      _(@ast.first[1].key?(:xdx)).must_equal true
    end

    it 'must have an :options key in the :start op hash' do
      _(@ast.first[1].key?(:options)).must_equal true
    end

    it 'must have 2 dice in the tree' do
      _(@ast.first[1][:xdx][:count]).must_equal 2
    end

    it 'must have 6-sided dice in the tree' do
      _(@ast.first[1][:xdx][:sides]).must_equal 6
    end
  end

  describe 'with a missing number of dice form' do
    before do
      tree = DiceBag::Parser.new.parse 'd6 e1 + 2'
      @ast = DiceBag::Transform.new.apply tree
    end

    it 'must default to having 1 die' do
      _(@ast.first[1][:xdx][:count]).must_equal 1
    end
  end
end
