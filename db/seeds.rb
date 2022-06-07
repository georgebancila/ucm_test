# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

buyer_user = User.find_or_create_by(username: 'buyer')
buyer_user.password = 'test'
buyer_user.deposit = 100
buyer_user.role = User::ROLES[:buyer]
buyer_user.save!

seller_user = User.find_or_create_by(username: 'seller')
seller_user.password = 'test'
seller_user.deposit = 100
seller_user.role = User::ROLES[:seller]
seller_user.save!

product_1 = Product.find_or_create_by(productName: 'soda')
product_1.amountAvailable = 20
product_1.cost = 20
product_1.seller = seller_user
product_1.save!

product_2 = Product.find_or_create_by(productName: 'chips')
product_2.amountAvailable = 20
product_2.cost = 25
product_2.seller = seller_user
product_2.save!
