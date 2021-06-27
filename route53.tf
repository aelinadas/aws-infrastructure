#Route 53 configuration
data "aws_route53_zone" "primary" {
  name = "${var.dns-name}"
}
#Route record
resource "aws_route53_record" "www" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${data.aws_route53_zone.primary.name}"
  type    = "A"

  alias {
    name = "${aws_lb.LoadBalancer.dns_name}"
    zone_id = "${aws_lb.LoadBalancer.zone_id}"
    evaluate_target_health = true
  }
}