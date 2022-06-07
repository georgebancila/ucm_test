# frozen_string_literal: true

module Request
  module JSONHelpers
    def parsed_body
      JSON.parse(response.body).with_indifferent_access
    end
  end
end
