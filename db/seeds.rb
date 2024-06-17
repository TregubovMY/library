# frozen_string_literal: true

5.times do
  title = Faker::Book.title #=> "The Odd Sister"
  author = Faker::Book.author #=> "Alysha Olsen"
  description = Faker::Lorem.paragraph(sentence_count: 5, supplemental: true, random_sentences_to_add: 4)
  available_books = total_books = Faker::Number.between(from: 0, to: 10)

  Book.create title:, author:, description:, total_books:, available_books:
end
