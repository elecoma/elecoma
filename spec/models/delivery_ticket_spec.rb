# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DeliveryTicket do
  fixtures :delivery_tickets
  before(:each) do
    @delivery_ticket = delivery_tickets :one
  end
  describe "validateチェック" do
    it "データがただしい" do
      @delivery_ticket.should be_valid
    end
  
    it "発送IDがないとエラー" do
      @delivery_ticket.order_delivery_id = nil
      @delivery_ticket.should_not be_valid
    end
  
    it "発送伝票番号がないとエラー" do
      @delivery_ticket.code = nil
      @delivery_ticket.should_not be_valid
    end
  end

end
