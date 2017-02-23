require "rails_helper"

RSpec.describe DnsRecordsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/communities/12/dns_hosted_zones/8/dns_records").to route_to("dns_records#index", :community_id => '12', :dns_hosted_zone_id => '8')
    end

    it "routes to #show" do
      expect(:get => "/communities/12/dns_hosted_zones/8/dns_records/1").to route_to("dns_records#show", :community_id => '12', :dns_hosted_zone_id => '8', :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/communities/12/dns_hosted_zones/8/dns_records").to route_to("dns_records#create", :community_id => '12', :dns_hosted_zone_id => '8')
    end

    it "routes to #update via PUT" do
      expect(:put => "/communities/12/dns_hosted_zones/8/dns_records/1").to route_to("dns_records#update", :community_id => '12', :dns_hosted_zone_id => '8', :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/communities/12/dns_hosted_zones/8/dns_records/1").to route_to("dns_records#update", :community_id => '12', :dns_hosted_zone_id => '8', :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/communities/12/dns_hosted_zones/8/dns_records/1").to route_to("dns_records#destroy", :community_id => '12', :dns_hosted_zone_id => '8', :id => "1")
    end

  end
end
