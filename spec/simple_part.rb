describe DiceBag::SimplePart do
  before do
    @part = DiceBag::SimplePart.new('test')
  end

  it 'should return the value as a result' do
    _(@part.result).must_equal 'test'
  end

  it 'should be the value as a string' do
    _(@part.to_s).must_equal 'test'
  end
end
