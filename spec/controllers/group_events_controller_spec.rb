require 'rails_helper'

RSpec.describe GroupEventsController, type: :controller do

  def response_body
    JSON.parse(response.body)
  end

  def sample_response_body_for(data)
    options = { each_serializer: GroupEventSerializer }
    serializable_resource = ActiveModel::SerializableResource.new(data, options)
    result = serializable_resource.as_json

    if result.is_a?(Array) && result.all? { |e| e.is_a?(Hash) }
      result.map &:with_indifferent_access
    elsif result.is_a?(Hash)
      result.with_indifferent_access
    end
  end

  describe 'GET #index' do
    before { create(:group_event) }
    let(:sample_response) { sample_response_body_for(GroupEvent.all) }

    it 'returns all group_events as json' do
      get :index
      expect(response_body).to eql(sample_response)
    end
  end

  describe 'GET #show' do
    subject { create(:group_event) }
    it 'returns the requested group_event as json' do
      get :show, params: { id: subject.id }
      expect(response_body).to eql(sample_response_body_for(subject))
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new group_event' do
        expect {
          post :create, params: { group_event: attributes_for(:group_event) }
        }.to change(GroupEvent, :count).by(1)
      end

      it 'returns created group_event as json' do
        post :create, params: { group_event: attributes_for(:group_event) }
        expect(response_body).to eql(sample_response_body_for(GroupEvent.last))
      end

      it 'creates group_event using start_date and duration params' do
        group_event_params = attributes_for(:group_event, duration: 3)
        group_event_params.delete(:end_date)

        post :create, params: { group_event:  group_event_params}
        expect(response_body['end_date']).to be_present
      end

      it 'creates group_event using end_date and duration params' do
        group_event_params = attributes_for(:group_event, duration: 3)
        group_event_params.delete(:start_date)

        post :create, params: { group_event:  group_event_params}
        expect(response_body['start_date']).to be_present
      end

      it 'responds with 201' do
        post :create, params: { group_event: attributes_for(:group_event) }
        expect(response.code).to eql('201')
      end
    end
  end

  describe 'PUT #update' do
    subject { create(:group_event) }
    let(:valid_attributes) { { name: 'New Name' } }
    let(:invalid_attributes) { { name: '' } }

    it 'updates group_event end_date using duration param' do
      put :update, params: { id: subject.id, group_event: {duration: 42} }
      subject.reload
      expect(subject.end_date).to eql(subject.start_date + 42)
    end

    context 'when event is published' do
      subject { create(:group_event, state: 'published') }
      context 'with valid params' do

        before { put :update, params: { id: subject.id, group_event: valid_attributes } }

        it 'updates the requested group_event with new values' do
          subject.reload
          expect(subject.name).to eql('New Name')
        end

        it 'returns updated group_event as json' do
          expect(response_body).to eql(sample_response_body_for(subject.reload))
        end

        it 'responds with 200' do
          expect(response.code).to eql('200')
        end
      end

      context 'with invalid params' do
        before { put :update, params: { id: subject.id, group_event: invalid_attributes } }

        it 'returns validation error' do
          expect(response_body).to eql({ "name" => ["can't be blank"] })
        end

        it 'responds with 422' do
          expect(response.code).to eql('422')
        end
      end
    end

    context 'when event is draft' do
      subject { create(:group_event, state: 'draft') }

      it 'updates the requested group_event with valid attributes' do
        put :update, params: { id: subject.id, group_event: valid_attributes }
        subject.reload
        expect(subject.name).to eql('New Name')
      end

      it 'updates the requested group_event with invalid attributes' do
        put :update, params: { id: subject.id, group_event: invalid_attributes }
        subject.reload
        expect(subject.name).to eql('')
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { create(:group_event) }
    before { subject }

    it 'destroys the requested group_event' do
      expect {
        delete :destroy, params: {id: subject.id}
      }.to change(GroupEvent, :count).by(-1)
    end

    it 'responds with 204' do
      delete :destroy, params: {id: subject.id}
      expect(response.code).to eql('204')
    end
  end

  describe 'PUT #publish' do
    before { put :publish, params: {id: subject.id} }

    context 'when event is valid' do
      subject { create(:group_event, state: 'draft') }

      it 'sets published state for requested group_event' do
        subject.reload
        expect(subject.state).to eql('published')
      end

      it 'responds with 204' do
        expect(response.code).to eql('204')
      end
    end

    context 'when event is invalid' do
      subject { create(:group_event, state: 'draft', name: nil) }

      it 'returns validation error' do
        expect(response_body).to eql({ "name" => ["can't be blank"] })
      end

      it 'responds with 422' do
        expect(response.code).to eql('422')
      end
    end

  end

  describe 'PUT #unpublish' do
    subject { create(:group_event, state: 'published') }
    before { put :unpublish, params: {id: subject.id} }

    it 'sets draft state for the requested group_event' do
      subject.reload
      expect(subject.state).to eql('draft')
    end

    it 'responds with 204' do
      expect(response.code).to eql('204')
    end
  end

end
