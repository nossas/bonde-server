class DnsRecordsController < ApplicationController
  before_action :set_dns_record, only: [:show, :update, :destroy]
  before_action :set_dns_hosted_zone

  # GET /dns_records
  # GET /dns_records.json
  def index
    authorize @dns_hosted_zone.community
    skip_policy_scope

    @dns_records = @dns_hosted_zone.dns_records

    render json: @dns_records
  end

  # GET /dns_records/1
  # GET /dns_records/1.json
  def show
    authorize @dns_record
    skip_policy_scope
    render json: @dns_record
  end

  # POST /dns_records
  # POST /dns_records.json
  def create
    authorize(@dns_hosted_zone.community)
    skip_policy_scope

    @dns_record = DnsRecord.new(dns_record_params)
    @dns_record.dns_hosted_zone = @dns_hosted_zone

    if @dns_record.save
      render json: @dns_record
    else
      render json: @dns_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dns_records/1
  # PATCH/PUT /dns_records/1.json
  def update
    authorize @dns_record
    skip_policy_scope

    if @dns_record.update(dns_record_params)
      head :no_content
    else
      render json: @dns_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /dns_records/1
  # DELETE /dns_records/1.json
  def destroy
    authorize @dns_record
    skip_policy_scope
    @dns_record.destroy

    head :no_content
  end

  private

    def set_dns_record
      @dns_record = DnsRecord.find(params[:id])
    end

    def set_dns_hosted_zone
      @dns_hosted_zone = DnsHostedZone.find params[:dns_hosted_zone_id]
    end

    def dns_record_params
      params.require(:dns_record).permit(:dns_hosted_zone_id, :name, :record_type, :value, :ttl)
    end
end
