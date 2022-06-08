# frozen_string_literal: true

class PurchasesService
  class CoinNotAcceptedError < StandardError; end

  class NotEnoughStockError < StandardError; end

  class NotEnoughMoneyError < StandardError; end

  class ValidationError < StandardError; end
  ACCEPTED_COINS = [5, 10, 20, 50, 100].freeze

  class << self
    def buy(attributes, user)
      response = {}
      product = Product.find(attributes[:product_id])

      validate_number('amount', attributes[:amount])

      amount = attributes[:amount].to_i
      total = amount * product.cost

      if amount > product.amountAvailable
        raise NotEnoughStockError,
              'There is not enough stock to purchase for the given amount'
      end

      if total > user.deposit
        raise NotEnoughMoneyError,
              'There is not enough money deposited to make the purchase'
      end

      product.amountAvailable -= amount
      product.save!

      remainder = user.deposit - total
      user.deposit = 0
      user.save!
      change = divide_amount(remainder)

      response[:total] = total
      response[:change] = change.sort
      response[:product] = product
      response[:amount] = amount

      response
    end

    def validate_number(name, number)
      raise ValidationError, "#{name.classify} must be an integer" unless number.match('\A[-+]?[0-9]+\z')
    end

    def divide_amount(amount)
      coins = []
      ACCEPTED_COINS.sort.reverse.each do |coin|
        number = amount / coin
        number.times do
          coins << coin
        end
        amount = amount % coin
      end

      coins
    end
  end
end
