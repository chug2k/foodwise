module Foodwise
  class Product < ActiveRecord::Base
    belongs_to :category

    validates_uniqueness_of :name, scope: :brand
  end
end
