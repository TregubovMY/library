# frozen_string_literal: true

module Books
  class CreateService < ::ApplicationService
    def initialize(params)
      super
      @params = params
    end

    def call
      tx_and_commit do
        @object = Book.build @params
        @object.save
      end

      super
    end

    private

    def post_call
      broadcast_later :books,
                      'books/created',
                      locals: { book: @object }
    end
  end
end
