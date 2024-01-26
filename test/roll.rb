# Encoding: UTF-8

describe DiceBag::Roll do
  before do
    @roll = DiceBag::Roll.new '(Dice Roll) 3d6 + 2 + 1d4'
  end

  describe 'before it is rolled' do
    it 'should store the dice string' do
      _(@roll.dstr).must_equal '(Dice Roll) 3d6 + 2 + 1d4'
    end

    it 'should have parsed tree' do
      _(@roll.tree).wont_be_nil
    end

    it 'should have a parsed tree of 4 items' do
      _(@roll.tree.size).must_equal 4
    end

    it 'should have a label part' do
      _(@roll.tree[0].last).must_be_instance_of DiceBag::LabelPart
    end

    it 'should have a roll part' do
      _(@roll.tree[1].last).must_be_instance_of DiceBag::RollPart
    end

    it 'should have a static part' do
      _(@roll.tree[2].last).must_be_instance_of DiceBag::StaticPart
    end
  end

  describe 'after it is rolled' do
    before do
      make_not_so_random!

      @roll.roll
    end

    it 'should have a non-nil result' do
      _(@roll.result).wont_be_nil
    end

    it 'should have a DiceBag::Result value' do
      _(@roll.result).must_be_instance_of DiceBag::Result
    end

    it 'should have a result total of 16' do
      _(@roll.result.total).must_equal 16
    end
  end
end
