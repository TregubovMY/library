30.times do
  title = Faker::Book.title #=> "The Odd Sister"
  author = Faker::Book.author #=> "Alysha Olsen"
  description = Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 4)

  Book.create title:, author:, description:
end
