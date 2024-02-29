describe DiceBag::Normalize do # rubocop:disable Metrics/BlockLength
  describe 'with a given an AST with just a single xdx string' do
    before do
      tree = DiceBag::Parser.new.parse '2d6'
      ast  = DiceBag::Transform.new.apply(tree)

      @result = DiceBag::Normalize.new(ast)
    end

    it 'it will be an instance of the Normalize class' do
      _(@result).must_be_instance_of DiceBag::Normalize
    end

    it 'will convert the argument into a single element array' do
      _(@result.ast).must_be_instance_of Array

      _(@result.ast.size).must_equal 1
    end
  end

  describe 'when given a dice string with and + static part' do
    before do
      tree = DiceBag::Parser.new.parse '2d6 + 5'
      ast  = DiceBag::Transform.new.apply(tree)

      @result = DiceBag::Normalize.call(ast)
    end

    it 'will have 2 sub arrays' do
      _(@result.size).must_equal 2
    end

    it 'will have the second array start with :add' do
      _(@result[1].first).must_equal :add
    end

    it 'will have the second array end with a StaticPart' do
      _(@result[1].last).must_be_instance_of DiceBag::StaticPart
    end

    it 'will have the second array with with a StaticPart value of 5' do
      _(@result[1].last.value).must_equal 5
    end
  end

  describe 'when given a dice string with and + roll part' do
    before do
      tree = DiceBag::Parser.new.parse '2d6 + 1d4'
      ast  = DiceBag::Transform.new.apply(tree)

      @result = DiceBag::Normalize.call(ast)
    end

    it 'will have 2 sub arrays' do
      _(@result.size).must_equal 2
    end

    it 'will have the second array start with :add' do
      _(@result[1].first).must_equal :add
    end

    it 'will have the second array end with a RollPart' do
      _(@result[1].last).must_be_instance_of DiceBag::RollPart
    end

    it 'will have the second array with with a RollPart value of a hash' do
      _(@result[1].last.value).must_be_instance_of Hash
    end
  end
end
