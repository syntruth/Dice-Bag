describe RollPartString do
  def roll_part_dstr
    @roll_part_dstr ||= '4d6 d1 k1 r2 t4'
  end

  before do
    @part = xdx(roll_part_dstr).first.last
  end

  it 'should reproduce the ROLL_PART_DSTR with spaces by default' do
    _(@part.to_s).must_equal roll_part_dstr
  end

  it 'should reproduce the ROLL_PART_DSTR without spaces with a true value' do
    _(@part.to_s(true)).must_equal roll_part_dstr.tr(' ', '')
  end
end
