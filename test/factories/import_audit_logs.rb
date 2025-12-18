FactoryBot.define do
  factory :import_audit_log do
    import_type { "restaurants" }
    status { %w[pending processing completed failed].sample }
    details { { "some_key" => "some_value" } }
    total_records { Faker::Number.between(from: 1, to: 100) }
    successful_records { Faker::Number.between(from: 0, to: total_records) }
    failed_records { total_records - successful_records }
    error_message { status == "failed" ? Faker::Lorem.sentence : nil }
    created_at { Faker::Time.between(from: 1.month.ago, to: Time.current) }
    completed_at { status != "pending" ? Faker::Time.between(from: created_at, to: Time.current) : nil }
  end
end
