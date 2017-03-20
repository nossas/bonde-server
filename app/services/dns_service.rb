class DnsService
  def create_hosted_zone hosted_zone, comment: '', private_zone: false
    route53.create_hosted_zone({
      name: hosted_zone,
      caller_reference: "#{DateTime.now.strftime('%Q')}#{rand(0..999)}",
      hosted_zone_config: {
        comment: comment,
        private_zone: private_zone
      }
    })
  end

  def delete_hosted_zone hosted_zone_id
    route53.delete_hosted_zone({ id: hosted_zone_id })
  end

  def change_resource_record_sets hosted_zone_id, domain_name, type, value, comment, action: 'UPSERT', ttl_seconds: 300# 3600
    resp = route53.change_resource_record_sets({
      change_batch: {
      changes: [
        {
          action: action, 
          resource_record_set: {
            name: domain_name, 
            resource_records: [
              {
                value: value, 
              }, 
            ], 
            ttl: ttl_seconds, 
            type: type, 
          }, 
        }, 
      ], 
      comment: comment, 
      }, 
      hosted_zone_id: hosted_zone_id, 
    })
  end

  def check_change change_id
    route53.get_change change_id
  end

  private

  def route53
    Aws::Route53::Client.new(region: (ENV['AWS_ROUTE53_REGION'] || 'sa-east-1'))
  end
end