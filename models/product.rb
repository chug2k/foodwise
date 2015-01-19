module Foodwise
  class Product < ActiveRecord::Base
    belongs_to :category
  end
end
