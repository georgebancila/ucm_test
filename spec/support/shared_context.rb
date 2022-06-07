# frozen_string_literal: true

RSpec.shared_context 'authenticate_request' do
  before(:each) do
    allow(controller).to receive(:authenticate_request).and_return(true)
  end
end
