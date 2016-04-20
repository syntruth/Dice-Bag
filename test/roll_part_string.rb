# Encoding: UTF-8

describe RollPartString do
  ROLL_PART_DSTR = '4d6 d1 k1 r2 t4'.freeze

  before do
    @part = xdx(ROLL_PART_DSTR).first.last
  end

  it 'should reproduce the ROLL_PART_DSTR with spaces by default' do
    @part.to_s.must_equal ROLL_PART_DSTR
  end

  it 'should reproduce the ROLL_PART_DSTR without spaces with a true value' do
    @part.to_s(true).must_equal ROLL_PART_DSTR.tr(' ', '')
  end
end
