# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthenticationController, type: :controller do
  describe '#login' do
    let(:password) { 'test' }
    let(:username) { 'rich_user' }
    let(:params) { { username: username, password: password } }

    let(:subject) { post :login, params: params }

    context 'when user exists' do
      let!(:user) { create(:user, username: username, password: password) }

      context 'when user credentials are correct' do
        it 'returns ok status' do
          subject
          expect(response).to have_http_status(:ok)
        end

        it 'returns a token' do
          subject
          expect(parsed_body[:token]).not_to be_nil
        end
      end

      context 'when user credentials are incorrect' do
        let!(:user) { create(:user, username: username, password: 'wrong') }
        it 'returns unauthorized status' do
          subject
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context 'when user does not exist' do
      it 'returns not_found status' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#logout_all' do
  end
end
