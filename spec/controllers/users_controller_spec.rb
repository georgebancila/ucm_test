# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  shared_examples 'an unauthorized request' do
    it 'returns unauthorized status' do
      subject
      expect(response).to have_http_status(:unauthorized)
    end
    it 'returns a message staging the error' do
      subject

      expect(parsed_body[:error]).to eq('You are allowed to see/edit/delete only your user')
    end
  end

  describe '#create' do
    include_context 'authenticate_request'

    let(:role) { User::ROLES[:seller] }
    let(:username) { 'test_user' }
    let(:deposit) { 50 }
    let(:password) { 'test_password' }
    let(:payload) { { username: username, deposit: deposit, role: role, password: password } }

    subject { post :create, params: payload }

    context 'when deposit is not a multiple of 5' do
      let(:deposit) { 42 }
      it 'returns an error' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'returns a message staging the error' do
        subject

        expect(parsed_body[:error]).to eq('Validation failed: Deposit must be a multiple of 5!')
      end
    end

    context 'when password length is less than 6' do
      let(:password) { 'six' }
      it 'returns an error' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'returns a message staging the error' do
        subject

        expect(parsed_body[:error]).to eq('Validation failed: Password is too short (minimum is 6 characters)')
      end
    end

    context 'when role is not alowed' do
      let(:role) { 'alien' }
      it 'returns an error' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'returns a message staging the error' do
        subject

        expect(parsed_body[:error]).to eq('Validation failed: Role is not included in the list')
      end
    end

    context 'when username already exists' do
      let!(:user_other) { create(:user, username: username) }

      it 'returns an error' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'returns a message staging the error' do
        subject

        expect(parsed_body[:error]).to eq('Validation failed: Username has already been taken')
      end
    end

    it 'creates a new user' do
      expect { subject }.to change { User.count }.by(1)
    end

    it 'returns ok status' do
      subject
      expect(response).to have_http_status(:created)
    end
  end

  describe '#update' do
    include_context 'authenticate_request'

    let!(:user) { create(:user) }
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    let(:payload) { { id: user.id, username: 'new-name' } }

    subject { patch :update, params: payload }

    it 'updates the name of the user' do
      subject
      user.reload
      expect(user.username).to eq 'new-name'
    end
  end

  describe '#destroy' do
    include_context 'authenticate_request'

    let!(:user) { create(:user) }
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context 'when user is current user' do
      subject { delete :destroy, params: { id: user.id } }

      it 'returns no_content status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes a user' do
        expect { subject }.to change { User.count }.by(-1)
      end
    end

    context 'when user is not current_user' do
      subject { delete :destroy, params: { id: 1234 } }
      it_behaves_like 'an unauthorized request'
    end
  end

  describe '#show' do
    include_context 'authenticate_request'

    let!(:user) { create(:user, username: 'test') }
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    subject { get :show, params: { id: user.id } }

    context 'when user is current_user' do
      it 'returns ok status' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'returns a user' do
        subject
        expect(parsed_body).to include(username: 'test')
      end
    end

    context 'when user is not current_user' do
      subject { get :show, params: { id: 1234 } }
      it_behaves_like 'an unauthorized request'
    end
  end
end
