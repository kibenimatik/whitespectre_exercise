require 'rails_helper'

RSpec.describe GroupEvent, type: :model do
  describe '#destroy' do
    subject { create(:group_event) }
    before { subject.destroy }

    it 'marks record as deleted' do
      expect(subject).to be_deleted
    end

    it 'keeps record in database' do
      expect(GroupEvent.with_deleted.count).to eql(1)
    end

    it 'does not returns deleted records in default scope' do
      expect(GroupEvent.count).to eql(0)
    end
  end

  describe '#duration' do
    context 'if both dates are present' do
      let(:start_date) { Date.today }
      let(:end_date) { start_date.next_week }
      subject { build(:group_event, start_date: start_date, end_date: end_date) }

      it 'returns distance in days between start and end dates' do
        expect(subject.duration).to eql(7)
      end
    end

    context 'if one of the date is not present' do
      subject { build(:group_event, end_date: nil) }
      it 'returns "undefined" text' do
        expect(subject.duration).to eql('undefined')
      end
    end
  end

  describe '#published!' do
    context 'when all fields present' do
      subject { create(:group_event, state: 'draft') }

      it 'returns true' do
        expect(subject.published!).to be true
      end

      it 'changes state to published' do
        subject.published! && subject.reload
        expect(subject.state).to eql('published')
      end
    end

    context 'when some fields are absent' do
      subject { create(:group_event, state: 'draft', location: nil)}

      it 'raises validation error' do
        expect { subject.published! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe '#draft!' do
    it 'changes state to draft' do
      subject = create(:group_event, state: 'published')
      subject.draft!
      expect(subject.state).to eql('draft')
    end
  end
end
