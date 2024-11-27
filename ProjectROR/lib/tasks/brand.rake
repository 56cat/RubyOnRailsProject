namespace :brand do
    task create: :environment do
        Brand.insert_all([
            {
                name: 'Đại lý',
                domain: 'dl',
                created_at: Time.now,
                updated_at: Time.now
            },
            {
                name: 'Thương hiệu',
                domain: 'th',
                created_at: Time.now,
                updated_at: Time.now
            },
            {
                name: 'Test',
                domain: 'test',
                created_at: Time.now,
                updated_at: Time.now
            },
        ])
    end
  end
  