#resource "aws_route53_zone" "aws-deploy" {
#  name = local.hosted_zone
#
#}
#
#resource "aws_route53_record" "aws-deploy" {
#  zone_id = aws_route53_zone.aws-deploy.id
#  name    = local.canonical_dns_name
#  type    = "A"
#
#  alias {
#    name                   = aws_lb.aws-deploy.dns_name
#    zone_id                = aws_lb.aws-deploy.zone_id
#    evaluate_target_health = true
#  }
#}
#
#resource "aws_acm_certificate" "aws-deploy" {
#  domain_name       = local.hosted_zone
#  validation_method = "DNS"
#}
#
## Create Certificate Validation
#resource "aws_acm_certificate_validation" "aws-deploy" {
#  certificate_arn         = aws_acm_certificate.aws-deploy.arn
#  validation_record_fqdns = [aws_route53_record.aws-deploy.fqdn]
#}
#
#resource "aws_route53_health_check" "aws-deploy" {
#  fqdn              = aws_route53_record.aws-deploy.fqdn
#  port              = local.container_port
#  type              = "HTTP"
#  resource_path     = local.healthcheck_path
#  failure_threshold = "5"
#}
#
#resource "aws_route53_record" "aws-deploy-certificate-validation-record" {
#  for_each = {
#    for dvo in aws_acm_certificate.aws-deploy.domain_validation_options : dvo.domain_name => {
#      name   = dvo.resource_record_name
#      record = dvo.resource_record_value
#      type   = dvo.resource_record_type
#    }
#  }
#  allow_overwrite = true
#  name            = each.value.name
#  records         = [each.value.record]
#  ttl             = 60
#  type            = each.value.type
#  zone_id         = aws_route53_zone.aws-deploy.id
#}
#
#resource "aws_acm_certificate_validation" "aws-deploy-certificate-validation-record" {
#  certificate_arn         = aws_acm_certificate.aws-deploy.arn
#  validation_record_fqdns = [for record in aws_route53_record.aws-deploy-certificate-validation-record : record.fqdn]
#}
