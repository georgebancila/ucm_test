# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PurchasesController, type: :controller do
  shared_context 'user has a seller role' do
    let!(:role) { 'seller' }

    it 'returns an error' do
      subject

      expect(response).to have_http_status(:unauthorized)
    end
    it 'returns a message staging the error' do
      subject

      expect(parsed_body[:error]).to eq('Only users with buyer role can make purchases')
    end
  end

  describe '#buy' do
    subject { post :buy, params: { amount: amount, product_id: product_id } }

    include_context 'authenticate_request'

    let(:user) { create(:user, role: role, deposit: deposit) }
    let(:role) { 'buyer' }
    let(:deposit) { 100 }
    let(:amount) { 1 }
    let(:product) { create(:product, cost: cost, amountAvailable: available_amount) }
    let(:product_id) { product.id }
    let(:cost) { 60 }
    let(:available_amount) { 50 }
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like 'user has a seller role'

    context 'when user has buyer role' do
      context 'when there is not enough stock' do
        let!(:amount) { 100 }
        it 'returns an error' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'returns a message staging the error' do
          subject

          expect(parsed_body[:error]).to eq('There is not enough stock to purchase for the given amount')
        end
      end
      context 'when there is not enough deposit' do
        let(:deposit) { 5 }
        it 'returns an error' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'returns a message staging the error' do
          subject

          expect(parsed_body[:error]).to eq('There is not enough money deposited to make the purchase')
        end
      end
      context 'when product does not exist' do
        let(:product_id) { 13_256 }
        it 'returns an error' do
          subject

          expect(response).to have_http_status(:not_found)
        end
        it 'returns a message staging the error' do
          subject

          expect(parsed_body[:error]).to eq("Couldn't find Product with 'id'=13256")
        end
      end
      context 'when amount is not a number' do
        let!(:amount) { 'string' }
        it 'returns an error' do
          subject

          expect(response).to have_http_status(:unprocessable_entity)
        end
        it 'returns a message staging the error' do
          subject

          expect(parsed_body[:error]).to eq('Amount must be an integer')
        end
      end

      it 'returns ok status' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'returns the change' do
        subject
        expect(parsed_body[:change]).to eq [20, 20]
      end

      it 'resets the user deposit' do
        expect { subject }.to change { user.deposit }.to(0)
      end

      it 'returns the purchased product' do
        subject
        expect(parsed_body[:product]).not_to be_nil
      end

      it 'returns the total payed amount' do
        subject
        expect(parsed_body[:total]).to eq 60
      end

      it 'decreases the amountAvailable on the product' do
        expect do
          subject
          product.reload
        end.to change { product.amountAvailable }.by(-1)
      end
    end
  end

  describe '#reset' do
    subject { post :reset }

    include_context 'authenticate_request'

    let!(:user) { create(:user, role: role, deposit: 100) }
    let!(:role) { 'buyer' }
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like 'user has a seller role'

    context 'when user has buyer role' do
      it 'resets the user deposit' do
        expect { subject }.to change { user.deposit }.to(0)
      end

      it 'returns the change' do
        subject
        expect(parsed_body[:change]).to eq [100]
      end

      it 'returns ok status' do
        subject
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe '#deposit' do
    include_context 'authenticate_request'

    let!(:user) { create(:user, role: role, deposit: 0) }
    let!(:role) { 'buyer' }
    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    subject { post :deposit, params: { coin: coin } }
    let(:coin) { 5 }

    context 'when user has buyer role' do
      it 'updates the deposit on the user' do
        expect { subject }.to change { user.deposit }.by(coin)
      end

      it 'returns ok status' do
        subject
        expect(response).to have_http_status(:ok)
      end

      context 'when coin is not allowed' do
        context 'because it is not a number' do
          let(:coin) { '123 312test' }

          it 'returns an error' do
            subject

            expect(response).to have_http_status(:unprocessable_entity)
          end
          it 'returns a message staging the error' do
            subject

            expect(parsed_body[:error]).to eq('Coin must be an integer')
          end
        end
        context 'because it does not match the coin rules' do
          let(:coin) { 6 }

          it 'returns an error' do
            subject

            expect(response).to have_http_status(:unprocessable_entity)
          end
          it 'returns a message staging the error' do
            subject

            expect(parsed_body[:error]).to eq('Coin not accepted, must be included in [5, 10, 20, 50, 100]')
          end
        end
      end
    end

    it_behaves_like 'user has a seller role'
  end
end
