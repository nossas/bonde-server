require "rails_helper"

RSpec.describe DnsHostedZonesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/communities/10/dns_hosted_zones").to route_to("dns_hosted_zones#index", :community_id => '10')
    end

    it "routes to #show" do
      expect(:get => "/communities/10/dns_hosted_zones/1").to route_to("dns_hosted_zones#show", :id => "1", :community_id => '10')
    end

    it "routes to #create" do
      expect(:post => "/communities/10/dns_hosted_zones").to route_to("dns_hosted_zones#create", :community_id => '10')
    end

    it "routes to #update via PUT" do
      expect(:put => "/communities/10/dns_hosted_zones/1").to route_to("dns_hosted_zones#update", :id => "1", :community_id => '10')
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/communities/10/dns_hosted_zones/1").to route_to("dns_hosted_zones#update", :id => "1", :community_id => '10')
    end

    it "routes to #destroy" do
      expect(:delete => "/communities/10/dns_hosted_zones/1").to route_to("dns_hosted_zones#destroy", :id => "1", :community_id => '10')
    end

  end
end
