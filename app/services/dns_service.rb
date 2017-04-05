class DnsService
  def create_hosted_zone hosted_zone, comment: '', private_zone: false
    route53.create_hosted_zone({
      name: hosted_zone,
      caller_reference: "#{DateTime.now.strftime('%Q')}#{rand(0..999)}",
      hosted_zone_config: {
        comment: comment,
        private_zone: private_zone
      }
    }) if can_i?
  end

  def get_hosted_zone id
    route53.get_hosted_zone({id: id})
  end

  def list_hosted_zones
    hosted_zones = []

    resp = route53.list_hosted_zones
    while (resp['is_truncated'])
      hosted_zones += (resp['hosted_zones'])
      resp = route53.list_hosted_zones({marker: resp['next_marker']})
    end
    hosted_zones += (resp['hosted_zones'])
    hosted_zones
  end

  def list_resource_record_sets hosted_zone_id
    resource_record_sets = []

    resp = route53.list_resource_record_sets({hosted_zone_id: hosted_zone_id})
    while (resp['is_truncated'])
      resource_record_sets += (resp['resource_record_sets'])
      resp = route53.list_resource_record_sets({hosted_zone_id: hosted_zone_id, start_record_name: resp['next_record_name']})
    end
    resource_record_sets += (resp['resource_record_sets'])
    resource_record_sets
  end

  def delete_hosted_zone hosted_zone_id
    route53.delete_hosted_zone({ id: hosted_zone_id }) if can_i?
  end

  def change_resource_record_sets hosted_zone_id, domain_name, type, values, comment, action: 'UPSERT', ttl_seconds: 300# 3600
    resp = route53.change_resource_record_sets({
      change_batch: {
      changes: [
        {
          action: action, 
          resource_record_set: {
            name: domain_name, 
            resource_records: values.map{|v| { value: v } }, 
            ttl: ttl_seconds, 
            type: type, 
          }, 
        }, 
      ], 
      comment: comment, 
      }, 
      hosted_zone_id: hosted_zone_id, 
    }) if can_i?
  end

  def check_change change_id
    route53.get_change(change_id) if can_i?
  end

  private

  def can_i?
    Rails.env.production? || ( ENV['BONDE_AWS_INTEGRATION'] == 'force' )
  end

  def route53
    Aws::Route53::Client.new(region: (ENV['AWS_ROUTE53_REGION'] || 'sa-east-1')) if can_i?
  end
end