require 'rails_helper'
RSpec.describe GroupEventSerializer, type: :serializer do
  let(:resource) { build(:group_event) }
  let(:serializer) { GroupEventSerializer.new(resource) }
  let(:serialization) { ActiveModel::Serializer::Adapter.create(serializer) }

  subject { JSON.parse(serialization.to_json) }

  %i[id name description location duration].each do |attr|
    it "has attribute: #{attr}" do
      expect(subject[attr.to_s]).to eql(resource.send(attr))
    end
  end

  %i[start_date end_date].each do |attr|
    it "has attribute: #{attr}" do
      expect(subject[attr.to_s]).to eql(resource.send(attr).iso8601)
    end
  end

  context 'when end_date not set' do
    let(:resource) { build(:group_event, end_date: nil) }
    it 'has not attribute: duration' do
      expect(subject['duration']).to be_nil
    end
  end

  context 'when start_date not set' do
    let(:resource) { build(:group_event, start_date: nil) }
    it 'has not attribute: duration' do
      expect(subject['duration']).to be_nil
    end
  end
end
