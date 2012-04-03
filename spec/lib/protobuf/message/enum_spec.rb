require 'spec_helper'
require 'spec/proto/test.pb'
require 'spec/proto/addressbook.pb'
require 'spec/proto/addressbook_base.pb'

describe Protobuf::Enum do

  describe Protobuf::EnumValue do
    context 'generic EnumValue API' do
      subject { Protobuf::EnumValue.new(Object, :test_enum_name, 100) }

      it { should be_a(Protobuf::EnumValue) }
      its(:name) { should eq :test_enum_name }
      its(:value) { should eq 100 }
      its(:to_s) { should eq 'test_enum_name' }
      specify { "#{subject}".should eq 'test_enum_name' }
      specify { 100.should eq(subject) }
      specify { subject.should eq(100) }
      specify { 101.should eq(subject + 1) }
      specify { (subject + 1).should eq(101) }
    end
  end

  describe 'enum field assignment' do
    let(:home_enum) { Tutorial::Person::PhoneType::HOME }
    subject { Tutorial::Person::PhoneNumber.new }
    its(:type) { should be_kind_of(Protobuf::EnumValue) }

    it 'accepts integer assignment' do
      subject.type = 1
      subject.type.should be_kind_of(Protobuf::EnumValue)
      subject.type.should eq home_enum
      subject.type.should eq 1
    end

    it 'accepts symbol assignment' do
      subject.type = :HOME
      subject.type.should be_kind_of(Protobuf::EnumValue)
      subject.type.should eq home_enum
      subject.type.should eq 1
    end

    it 'accepts enum assignment' do
      subject.type = home_enum
      subject.type.should be_kind_of(Protobuf::EnumValue)
      subject.type.should eq home_enum
      subject.type.should eq 1
    end

    context 'when integer is outside enum range' do
      it 'rejects integer assignment' do
        expect do
          subject.type = 4
        end.should raise_error(TypeError)
      end
    end

    context 'when symbol doesn\'t match enum field' do
      it 'rejects symbol assignment' do
        expect do
          subject.type = :USA
        end.should raise_error(TypeError)
      end
    end

    context 'when enum is not of same type' do
      it 'rejects enum assignment' do
        expect do
          subject.type = TutorialExt::Person::PhoneType::HOME
        end.should raise_error(TypeError)
      end
    end
  end

  context 'when coercing' do
    subject { Spec::Proto::StatusType::PENDING }

    context 'from enum to integer' do
      specify { subject.should eq 0 }
      specify { subject.should_not eq 1 }
      specify { (subject == 0).should be_true }
      specify { (subject == 1).should be_false }
    end

    context 'from integer to enum' do
      specify { 0.should eq subject }
      specify { 1.should_not eq subject }
      specify { (0 == subject).should be_true }
      specify { (1 == subject).should be_false }
    end
  end
end
