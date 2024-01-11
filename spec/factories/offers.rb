FactoryBot.define do
  factory :offer do
    title { "MyString" }
    description { "MyText" }
    photo_urls { "MyText" }
    product_options { "MyText" }
    ratings { 1.5 }
    feedbacks { "MyText" }
    price { "9.99" }
    user { nil }
  end
end
