# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ErrorHandling
  include Internationalization
end
