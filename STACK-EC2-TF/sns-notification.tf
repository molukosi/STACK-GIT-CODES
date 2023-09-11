resource "aws_sns_topic" "test_notification" {
  name = "test_notification_topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.test_notification.arn
  protocol  = "email"
  endpoint  = "stackcloud10@mkitconsulting.net"
}