# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductsController, type: :controller do
  describe '#show' do
    include_context 'authenticate_request'

    let!(:product) { create(:product, productName: 'cola') }
    subject { get :show, params: { id: product.id } }

    context 'when product exists' do
      it 'returns ok status' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'returns a product' do
        subject
        expect(parsed_body).to include(productName: 'cola')
      end
    end

    context 'when product does not exist' do
      subject { get :show, params: { id: 1234 } }
      it 'returns not_found status' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#create' do
    include_context 'authenticate_request'

    let(:role) { User::ROLES[:seller] }
    let(:current_user) { create(:user, role: role) }
    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    let(:productName) { 'colacoca' }
    let(:cost) { 50 }
    let(:payload) { { productName: productName, amountAvailable: 100, cost: cost } }

    subject { post :create, params: payload }

    context 'when cost is not a multiple of 5' do
      let(:cost) { 42 }
      it 'returns an error' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'returns a message staging the error' do
        subject

        expect(parsed_body[:error]).to eq('Validation failed: Cost must be a multiple of 5!')
      end
    end

    context 'when current user is not a seller' do
      let(:role) { User::ROLES[:buyer] }
      let(:cost) { 42 }
      it 'returns an error' do
        subject

        expect(response).to have_http_status(:method_not_allowed)
      end
      it 'returns a message staging the error' do
        subject

        expect(parsed_body[:error]).to eq('Only a seller user can add products')
      end
    end

    context 'when productName already exists' do
      let!(:product) { create(:product, productName: productName) }

      it 'returns an error' do
        subject

        expect(response).to have_http_status(:unprocessable_entity)
      end
      it 'returns a message staging the error' do
        subject

        expect(parsed_body[:error]).to eq('Validation failed: Productname has already been taken')
      end
    end

    it 'creates a new product' do
      expect { subject }.to change { Product.count }.by(1)
    end

    it 'returns ok status' do
      subject
      expect(response).to have_http_status(:created)
    end
  end

  describe '#update' do
    include_context 'authenticate_request'

    let!(:product) { create(:product) }
    let(:current_user) { product.seller }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    let(:payload) { { id: product.id, productName: 'new-name' } }

    subject { patch :update, params: payload }

    it 'updates the name of the product' do
      subject
      product.reload
      expect(product.productName).to eq 'new-name'
    end
  end

  describe '#destroy' do
    include_context 'authenticate_request'

    context 'when product exists' do
      let!(:product) { create(:product, productName: 'cola') }
      let(:current_user) { product.seller }

      before do
        allow(controller).to receive(:current_user).and_return(current_user)
      end

      subject { delete :destroy, params: { id: product.id } }

      it 'returns no_content status' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'deletes a product' do
        expect { subject }.to change { Product.count }.by(-1)
      end
    end

    context 'when product does not exist' do
      subject { delete :destroy, params: { id: 1234 } }
      it 'returns not_found status' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
