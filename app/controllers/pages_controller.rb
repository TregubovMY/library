# frozen_string_literal: true

class PagesController < ApplicationController
  def index
    add_breadcrumb t('shared.menu.home'), root_path
  end
end
