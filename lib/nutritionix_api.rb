module Foodwise
  class NutritionixAPI
    include HTTParty
    # TODO(Charles): Remove API Creds from code.
    headers 'X-APP-ID' => '266bd272', 'X-APP-KEY' => '7e23f2c2d4c7f98a3631d6bf0d047257'

    base_uri 'https://apibeta.nutritionix.com/v2'

    def item(id)
      self.class.get("/item/#{id}").parsed_response.deep_symbolize_keys
    end
  end



end