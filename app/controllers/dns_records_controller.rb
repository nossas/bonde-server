class DnsRecordsController < ApplicationController
  before_action :set_dns_record, only: [:show, :update, :destroy]
  before_action :set_dns_hosted_zone

  # GET /dns_records
  # GET /dns_records.json
  def index
    render_404 and return if (! @dns_hosted_zone ) || ("#{@dns_hosted_zone.community.id}" != params[:community_id])
    authorize @dns_hosted_zone.community
    skip_policy_scope

    @dns_records = @dns_hosted_zone.dns_records
    @dns_records = @dns_records.only_unsensible unless params[:full_data] == 'true'
      
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
    @dns_record = DnsRecord.new(dns_record_params(true))
    @dns_record.dns_hosted_zone = @dns_hosted_zone

    
    authorize(@dns_hosted_zone.community)
    skip_policy_scope

    is_subdomain = (@dns_record.name =~ eval("/#{@dns_record.dns_hosted_zone.domain_name.gsub(/\./, '\.')}$/"))
    render json: { errors: [I18n.t('activerecord.errors.duplicated')] }, status: :unprocessable_entity and return if DnsRecord.where('name=? and record_type=?', @dns_record.name, @dns_record.record_type).count > 0 
    if @dns_record.validate && is_subdomain
      @dns_record.save
      render json: @dns_record
    else
      errors = @dns_record.errors.clone
      errors[:name] << I18n.t('aws.route53.errors.subdomain') unless is_subdomain

      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /dns_records/1
  # PATCH/PUT /dns_records/1.json
  def update
    authorize @dns_record
    skip_policy_scope

    if @dns_record.update(dns_record_params(false))
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

    def render_404
      skip_authorization
      skip_policy_scope
      render nothing:true, status: :not_found
    end

    def set_dns_record
      @dns_record = DnsRecord.find(params[:id])
    end

    def set_dns_hosted_zone
      @dns_hosted_zone = DnsHostedZone.find_by_id params[:dns_hosted_zone_id]
    end

    def dns_record_params new_record
      if params[:dns_record]
        if new_record
          return params.require(:dns_record).permit(policy(DnsRecord.new dns_hosted_zone:@dns_hosted_zone).permitted_attributes_for_create)
        else
          return params.require(:dns_record).permit(policy(@dns_record).permitted_attributes_for_update)
        end
      end
      {}
    end
end
