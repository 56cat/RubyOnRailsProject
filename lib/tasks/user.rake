
require 'faker'
require 'faker'
Faker::Config.locale = 'vi'
namespace :user do
  task create_super_admin: :environment do
    User.create!({
      name: 'Quản trị viên',
      phone: '0388898690',
      role: 0,
      email: 'nam.nguyen@gmail.com',
      password: '061020',
      brand_id: nil,
      is_active: true
    }) 
  end

  task create_suppler: :environment do
    if Brand.any?
      user = []
      Brand.pluck(:id).each do |brand_id|
        User.create!({
          name: Faker::Name.name,
          phone: Faker::PhoneNumber.unique.phone_number.delete(' '),
          role: 1,
          email: Faker::Internet.unique.email(domain: 'gmail.com'),
          password: '061020',
          brand_id: brand_id,
          is_active: true
        })
      end
    else
      puts 'Chưa có đại lý nào run rake brand:create'
    end
  end

  task create_user: :environment do
    5.times.each do |id|
      User.create!({
        name: Faker::Name.name,
        phone: Faker::PhoneNumber.unique.phone_number.delete(' '),
        role: 3,
        email: Faker::Internet.unique.email(domain: 'gmail.com'),
        password: '061020',
        is_active: true
      })
    end
   
  end

end
