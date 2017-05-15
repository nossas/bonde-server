require 'rails_helper'


RSpec.describe DnsRecordsController, type: :controller do
  before do
    allow_any_instance_of(DnsService).to receive(:create_hosted_zone).and_return({
      'delegation_set' => { 'name_servers' => ["ns-1258.awsdns-29.org", "ns-826.awsdns-39.net", "ns-55.awsdns-06.com", "ns-1552.awsdns-02.co.uk"] },
      'hosted_zone' => {'id' => '12312312'}
    })
    allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
    allow_any_instance_of(DnsService).to receive(:list_resource_record_sets).and_return([])
    allow_any_instance_of(DnsService).to receive(:list_hosted_zones).and_return([])
  end

  let!(:dns_hosted_zone) { create :dns_hosted_zone }
  let!(:community) { dns_hosted_zone.community }
  let!(:user) { create :user }

  before do
    CommunityUser.create user: user, community: community, role: 1
    stub_current_user user
  end

  # This should return the minimal set of attributes required to create a valid
  # DnsRecord. As you add validations to DnsRecord, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      name: "www.#{dns_hosted_zone.domain_name}",
      record_type: "AAAA",
      value: "fe80::6668:f729:dbce:7441/64",
      ttl: 3600
    }
  }

  let(:invalid_attributes) {
    {
      name: nil,
      record_type: nil,
      value: "192.168.0.1",
      ttl: 3600
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DnsRecordsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    let!(:dns_records) { [
      create(:dns_record, name: "#{dns_hosted_zone.domain_name}", record_type: 'SOA', dns_hosted_zone: dns_hosted_zone),
      create(:dns_record, name: "#{dns_hosted_zone.domain_name}", record_type: 'NS', dns_hosted_zone: dns_hosted_zone),
      create(:dns_record, name: "#{dns_hosted_zone.domain_name}", record_type: 'A', dns_hosted_zone: dns_hosted_zone),
      create(:dns_record, name: "#{dns_hosted_zone.domain_name}", record_type: 'AAAA', dns_hosted_zone: dns_hosted_zone),
      create(:dns_record, name: "*.#{dns_hosted_zone.domain_name}", record_type: 'A', dns_hosted_zone: dns_hosted_zone),
      create(:dns_record, name: "*.#{dns_hosted_zone.domain_name}", record_type: 'AAAA', dns_hosted_zone: dns_hosted_zone),
      create(:dns_record, name: "*.#{dns_hosted_zone.domain_name}", record_type: 'CNAME', dns_hosted_zone: dns_hosted_zone),
      create(:dns_record, dns_hosted_zone: dns_hosted_zone)
    ] }

    it "assigns all dns_records as @dns_records" do
      get :index, { dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, full_data: 'true'}

      dns_records.each{|r| expect(assigns(:dns_records)).to include(r) }
      expect(assigns(:dns_records).size).to be dns_records.size
    end

    it "assigns all dns_records as @dns_records" do
      get :index, { dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id}

      dns_records.each{|r| expect(assigns(:dns_records)).to include(dns_records.last) }
      expect(assigns(:dns_records).size).to be 1
    end
  end

  describe "GET #show" do
    it "assigns the requested dns_record as @dns_record" do
      dns_record = create(:dns_record, dns_hosted_zone: dns_hosted_zone)
      get :show, { dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, id: dns_record.id}
      expect(assigns(:dns_record)).to eq(dns_record)
    end
  end

# dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id,

  describe "POST #create" do
    context "with valid params" do
      it "creates a new DnsRecord" do
        expect {
          post :create, {dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, dns_record: valid_attributes}
        }.to change(DnsRecord, :count).by(1)
      end

      it "assigns a newly created dns_record as @dns_record" do
        post :create, {dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, dns_record: valid_attributes, format: :json}
        expect(assigns(:dns_record)).to be_a(DnsRecord)
        expect(assigns(:dns_record)).to be_persisted
      end
    end

    context "with invalid params" do
      before do
        post :create, {dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, dns_record: invalid_attributes}
      end

      it "assigns a newly created but unsaved dns_record as @dns_record" do
        expect(assigns(:dns_record)).to be_a_new(DnsRecord)
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT #update" do
    let!(:dns_record) { create(:dns_record, dns_hosted_zone: dns_hosted_zone) }

    before do
      put :update, {dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, id: dns_record.to_param, dns_record: valid_attributes}
    end
    

    context "with valid params" do
      it "updates the requested dns_record" do
        dns_record.reload

        expect(dns_record.record_type).to eq("AAAA")
        expect(dns_record.value).to eq("fe80::6668:f729:dbce:7441/64")
      end

      it "assigns the requested dns_record as @dns_record" do
        expect(assigns(:dns_record)).to eq(dns_record)
      end
    end

    context "with invalid params" do
      before do
        put :update, {dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, id: dns_record.to_param, dns_record: invalid_attributes}
      end
      it "assigns the dns_record as @dns_record" do
        expect(assigns(:dns_record)).to eq(dns_record)
      end
      it { should respond_with 422 }
    end
  end

  describe "DELETE #destroy" do
    let!(:dns_record) { create(:dns_record, dns_hosted_zone: dns_hosted_zone) }

    it "destroys the requested dns_record" do
      expect {
        delete :destroy, {dns_hosted_zone_id: dns_hosted_zone.id, community_id: community.id, id: dns_record.to_param}
      }.to change(DnsRecord, :count).by(-1)
    end
  end

end
