# Encoding: UTF-8

describe RollString do
  ROLL_DSTR = '(Test) 4d6 d1 k1 r2 t4'.freeze

  before do
    @roll = DiceBag::Roll.new ROLL_DSTR
  end

  it 'should reproduce the ROLL_DSTR with spaces by default' do
    @roll.to_s.must_equal ROLL_DSTR
  end

  it 'should reproduce the ROLL_DSTR without spaces with a true value' do
    @roll.to_s(true).must_equal ROLL_DSTR.tr(' ', '')
  end
end
