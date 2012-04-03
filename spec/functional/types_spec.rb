require 'spec_helper'
require 'spec/proto/types.pb'

describe Test::Types::TestTypes do
  subject { described_class.new }

  it 'serializes all protobuf field types' do
    subject.type1 = 0.01
    subject.type2 = 0.1
    subject.type3 = 1
    subject.type4 = 10
    subject.type5 = 100
    subject.type6 = 1000
    subject.type7 = -1
    subject.type8 = -10
    subject.type9 = 10000
    subject.type10 = 100000
    subject.type11 = false
    subject.type12 = 'hello all types'
    image_bin = File.open('test/data/unk.png', 'r+b'){|f| f.read}
    subject.type13 = image_bin
    subject.type14 = -100
    subject.type15 = -1000

    serialized_string = subject.serialize_to_string

    parsed = described_class.new
    parsed.parse_from_string(serialized_string)

    parsed.type1.should be_within(0.00001).of(0.01)
    parsed.type2.should be_within(0.00001).of(0.1)
    parsed.type3.should eq 1
    parsed.type4.should eq 10
    parsed.type5.should eq 100
    parsed.type6.should eq 1000
    parsed.type7.should eq -1
    parsed.type8.should eq -10
    parsed.type9.should eq 10000
    parsed.type10.should eq 100000
    parsed.type11.should be_false
    parsed.type12.should eq 'hello all types'
    parsed.type13.size.should eq 10938
    parsed.type13.should eq image_bin
    parsed.type14.should eq -100
    parsed.type15.should eq -1000
  end

  it 'serializes field boundaries as well' do
    subject.type1 = 1.0/0   # double (Inf)
    subject.type2 = -1.0/0  # float (-Inf)
    subject.type3 = -1      # int32
    subject.type4 = -10     # int64
    subject.type5 = 100     # uint32
    subject.type6 = 1000    # uint64
    subject.type7 = -1000   # sint32
    subject.type8 = -10000  # sint64
    subject.type9 = 10000   # fixed32
    subject.type10 = 100000 # fixed64
    subject.type11 = true
    subject.type12 = 'hello all types'
    image_bin = File.open('test/data/unk.png', 'r+b'){|f| f.read}
    subject.type13 = image_bin
    subject.type14 = -2_000_000_000  # sfixed32
    subject.type15 = -8_000_000_000_000_000_000  # sfixed64

    serialized_string = subject.serialize_to_string

    parsed = described_class.new
    parsed.parse_from_string(serialized_string)

    parsed.type1.should eq(1.0/0.0)
    parsed.type2.should eq(-1.0/0.0)
    parsed.type3.should eq -1
    parsed.type4.should eq -10
    parsed.type5.should eq 100
    parsed.type6.should eq 1000
    parsed.type7.should eq -1000
    parsed.type8.should eq -10000
    parsed.type9.should eq 10000
    parsed.type10.should eq 100000
    parsed.type11.should be_true
    parsed.type12.should eq 'hello all types'
    parsed.type13.size.should eq 10938
    parsed.type13.should eq image_bin
    parsed.type14.should eq -2_000_000_000
    parsed.type15.should eq -8_000_000_000_000_000_000
  end

  it 'parses types correctly from serialized proto bytes' do
    subject.parse_from_file('test/data/types.bin')
    subject.type1.should be_within(0.00001).of(0.01)
    subject.type2.should be_within(0.00001).of(0.1)

    subject.type3.should eq 1
    subject.type4.should eq 10
    subject.type5.should eq 100
    subject.type6.should eq 1000
    subject.type7.should eq -1
    subject.type8.should eq -10
    subject.type9.should eq 10000
    subject.type10.should eq 100000
    (!!subject.type11).should be_false
    subject.type12.should eq 'hello all types'
    subject.type13.should eq File.open('spec/data/unk.png', 'r+b'){|f| f.read}
  end

  it 'supports double fixed 64-bit)' do
    expect { subject.type1 = 1 }.to_not raise_error
    expect { subject.type1 = 1.0 }.to_not raise_error
    expect { subject.type1 = Protobuf::Field::DoubleField.max }.to_not raise_error
    expect { subject.type1 = Protobuf::Field::DoubleField.min }.to_not raise_error
    expect { subject.type1 = '' }.to raise_error(TypeError)
  end

  it 'support float fixed 32-bit' do
    expect { subject.type2 = 1 }.to_not raise_error
    expect { subject.type2 = 1.0 }.to_not raise_error
    expect { subject.type2 = Protobuf::Field::FloatField.max }.to_not raise_error
    expect { subject.type2 = Protobuf::Field::FloatField.min }.to_not raise_error
    expect { subject.type2 = '' }.to raise_error(TypeError)
  end

  it 'supports int32' do
    expect { subject.type3 = 1 }.to_not raise_error
    expect { subject.type3 = -1 }.to_not raise_error
    expect { subject.type3 = 1.0 }.to raise_error(TypeError)
    expect { subject.type3 = '' }.to raise_error(TypeError)
  end

  it 'supports int64' do
    expect { subject.type4 = 1 }.to_not raise_error
    expect { subject.type4 = -1 }.to_not raise_error
    expect { subject.type4 = 1.0 }.to raise_error(TypeError)
    expect { subject.type4 = '' }.to raise_error(TypeError)
  end

  it 'supports uint32' do
    expect { subject.type5 = 1 }.to_not raise_error
    expect { subject.type5 = -1 }.to raise_error(RangeError)
    expect { subject.type5 = 1.0 }.to raise_error(TypeError)
    expect { subject.type5 = '' }.to raise_error(TypeError)
  end

  it 'supports uint64' do
    expect { subject.type6 = 1 }.to_not raise_error
    expect { subject.type6 = -1 }.to raise_error(RangeError)
    expect { subject.type6 = 1.0 }.to raise_error(TypeError)
    expect { subject.type6 = '' }.to raise_error(TypeError)
  end

  it 'supports sint32' do
    expect { subject.type7 = 1 }.to_not raise_error
    expect { subject.type7 = -1 }.to_not raise_error
    expect { subject.type7 = 1.0 }.to raise_error(TypeError)
    expect { subject.type7 = '' }.to raise_error(TypeError)
  end

  it 'supports sint64' do
    expect { subject.type8 = 1 }.to_not raise_error
    expect { subject.type8 = -1 }.to_not raise_error
    expect { subject.type8 = 1.0 }.to raise_error(TypeError)
    expect { subject.type8 = '' }.to raise_error(TypeError)
  end

  it 'supports fixed32' do
    expect { subject.type9 = 1 }.to_not raise_error
    expect { subject.type9 = Protobuf::Field::Fixed32Field.max }.to_not raise_error
    expect { subject.type9 = Protobuf::Field::Fixed32Field.min }.to_not raise_error
    expect { subject.type9 = 1.0 }.to raise_error(TypeError)
    expect { subject.type9 = '' }.to raise_error(TypeError)
    expect { subject.type9 = Protobuf::Field::Fixed32Field.max + 1 }.to raise_error(RangeError)
    expect { subject.type9 = Protobuf::Field::Fixed32Field.min - 1 }.to raise_error(RangeError)
  end

  it 'supports fixed64' do
    expect { subject.type10 = 1 }.to_not raise_error
    expect { subject.type10 = Protobuf::Field::Fixed64Field.max }.to_not raise_error
    expect { subject.type10 = Protobuf::Field::Fixed64Field.min }.to_not raise_error
    expect { subject.type10 = 1.0 }.to raise_error(TypeError)
    expect { subject.type10 = '' }.to raise_error(TypeError)
    expect { subject.type10 = Protobuf::Field::Fixed64Field.max + 1 }.to raise_error(RangeError)
    expect { subject.type10 = Protobuf::Field::Fixed64Field.min - 1 }.to raise_error(RangeError)
  end

  it 'supports bool' do
    expect { subject.type11 = true }.to_not raise_error
    expect { subject.type11 = false }.to_not raise_error
    expect { subject.type11 = nil }.to_not raise_error
    expect { subject.type11 = 0 }.to raise_error(TypeError)
    expect { subject.type11 = '' }.to raise_error(TypeError)
  end

  it 'supports string' do
    expect { subject.type12 = '' }.to_not raise_error
    expect { subject.type12 = 'hello' }.to_not raise_error
    expect { subject.type12 = nil }.to_not raise_error
    expect { subject.type12 = 0 }.to raise_error(TypeError)
    expect { subject.type12 = true }.to raise_error(TypeError)
  end

  it 'supports bytes fields' do
    expect { subject.type13 = '' }.to_not raise_error
    expect { subject.type13 = 'hello' }.to_not raise_error
    expect { subject.type13 = nil }.to_not raise_error
    expect { subject.type13 = 0 }.to raise_error(TypeError)
    expect { subject.type13 = true }.to raise_error(TypeError)
    expect { subject.type13 = [] }.to raise_error(TypeError)
  end

  it 'supports varint getbytes' do
    Protobuf::Field::VarintField.encode(300).should eq "\xac\x02"
  end
end
