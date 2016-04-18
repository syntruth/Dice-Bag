# Encoding: UTF-8

describe DiceBag::StaticPart do
  before do
    @part = DiceBag::StaticPart.new '5'
  end

  it 'always uses an fixnum' do
    @part.value.must_be_instance_of Fixnum
  end

  it 'returns the value as the total' do
    @part.total.must_equal 5
  end

  it 'return the value as a string when converted to a string' do
    @part.to_s.must_equal '5'
  end
end
