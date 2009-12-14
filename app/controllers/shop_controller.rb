class ShopController < BaseController

  def show
  end

  def about
    @shop = Shop.first
  end
end
