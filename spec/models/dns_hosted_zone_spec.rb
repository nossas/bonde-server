require 'rails_helper'

RSpec.describe DnsHostedZone, type: :model do
  before do
    allow_any_instance_of(DnsService).to receive(:create_hosted_zone)
    allow_any_instance_of(DnsService).to receive(:list_hosted_zones).and_return([])
    allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
  end

  subject { build :dns_hosted_zone, community: (create :community) }

  it { should belong_to :community }
  
  it { should have_many :users }
  it { should have_many :dns_records }

  it { should validate_presence_of :community_id }
  it { should validate_presence_of :domain_name }
  it { should validate_length_of(:domain_name).is_at_most(255) }


  describe '#delete_hosted_zone' do
    before do
      subject.save!
      create(:dns_record, dns_hosted_zone: subject)
      create(:dns_record, dns_hosted_zone: subject, name: "*.#{subject.domain_name}")
      subject.reload
    end

    it 'should delete all children dns_records' do 
      expect{ subject.delete_hosted_zone }.to change{DnsRecord.count}.by -2
    end

    it 'should remove from aws ' do
      allow_any_instance_of(DnsService).to receive(:change_resource_record_sets)
      subject.delete_hosted_zone
    end
  end

  describe '#check_ns_correctly_filled!' do
    context 'already checked' do
      before do
        subject.update_attributes ns_ok: true
      end

      it {expect(subject.check_ns_correctly_filled!).to be}

      it do
        expect_any_instance_of(DnsHostedZone).not_to receive(:compare_ns)

        subject.check_ns_correctly_filled!
      end
    end

    context 'not checked' do
      before do
        subject.update_attributes ns_ok: false
      end

      [false, true].each do |contexto|
        context "#{contexto}" do
          before do
            expect_any_instance_of(DnsHostedZone).to receive(:compare_ns).and_return(contexto)
          end
        
          it { expect(subject.check_ns_correctly_filled!).to be contexto }

          it do
            older = subject.updated_at
            subject.check_ns_correctly_filled!
            expect(subject.updated_at != older).to be contexto
          end
        end
      end
    end
  end
end
