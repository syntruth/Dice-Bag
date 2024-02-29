describe DiceBag::Result do
  before do
    make_not_so_random!

    @result = DiceBag::Roll.new('(Dice Roll) 3d6 + 5 - 1d4').roll
  end

  it 'must have 3 sections' do
    _(@result.sections.size).must_equal 3
  end

  it 'must have a total of 13' do
    _(@result.total).must_equal 13
  end

  it 'must display a label and total string' do
    _(@result.to_s).must_equal 'Dice Roll: 13'
  end
end
