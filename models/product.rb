module Foodwise
  class Product < ActiveRecord::Base
    belongs_to :category

    validates_uniqueness_of :name, scope: :brand

    def category_name
      self.category.name
    end

    def as_json(opts={})
      super(opts.merge(methods: :category_name))
    end
  end

end
