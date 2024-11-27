require 'faker'

namespace :product do
    task create: :environment do
        products = []
        100.times.each do |id|
            products << {
                name: Faker::Food.fruits,
                created_at: Time.now,
                updated_at: Time.now
            }
         end
         Product.insert_all(products)
    end
end
