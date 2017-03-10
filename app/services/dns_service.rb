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

  private

  def route53
    Aws::Route53::Client.new(region: (ENV['AWS_ROUTE53_REGION'] || 'sa-east-1'))
  end
end