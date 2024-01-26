# Encoding: UTF-8

describe DiceBag::StaticPart do
  before do
    @part = DiceBag::StaticPart.new '5'
  end

  it 'always uses an fixnum' do
    _(@part.value).must_be_instance_of Integer
  end

  it 'returns the value as the total' do
    _(@part.total).must_equal 5
  end

  it 'return the value as a string when converted to a string' do
    _(@part.to_s).must_equal '5'
  end
end
