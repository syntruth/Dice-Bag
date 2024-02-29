describe DiceBag::LabelPart do
  before do
    @part = DiceBag::LabelPart.new('test')
  end

  it 'must return the value in parenthesis as a string' do
    _(@part.to_s).must_equal '(test)'
  end
end
