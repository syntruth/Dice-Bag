describe RollString do
  def roll_dstr
    @roll_dstr ||= '(Test) 4d6 d1 k1 r2 t4'
  end

  before do
    @roll = DiceBag::Roll.new roll_dstr
  end

  it 'should reproduce the dice string with spaces by default' do
    _(@roll.to_s).must_equal roll_dstr
  end

  it 'should reproduce the dice string without spaces with a true value' do
    _(@roll.to_s(true)).must_equal roll_dstr.tr(' ', '')
  end
end
