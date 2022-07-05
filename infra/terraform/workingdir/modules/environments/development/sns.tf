resource "aws_sns_topic" "data_sns" {
  name            = "${var.deployment}-sns"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false
  }
}
EOF
  tags            = var.tags
}

resource "aws_sns_topic_subscription" "sns_to_sqs" {
  depends_on = [
    module.aws_data_pipeline,
    aws_sns_topic.data_sns,
    aws_sns_topic_policy.data_sns
  ]
  for_each       = module.aws_data_pipeline.sqs_etl_arns
  topic_arn      = aws_sns_topic.data_sns.arn
  protocol       = "sqs"
  endpoint       = each.value
  filter_policy  = <<EOF
  {
    "event": ["${each.key}"]
  }
EOF
  redrive_policy = <<EOF
  {
    "DeadLetterTargetArn": "${module.aws_data_pipeline.sns_deadletter}"
  }
EOF
}

####################### SNS SUPPORTING RESOURCES #########################

#SNS Topic Policy
resource "aws_sns_topic_policy" "data_sns" {
  arn    = aws_sns_topic.data_sns.arn
  policy = data.aws_iam_policy_document.ssm_params_sns.json
}

# SNS Policy Document
data "aws_iam_policy_document" "ssm_params_sns" {

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:RemovePermission",
      "SNS:DeleteTopic",
      "SNS:Subscribe",
      "SNS:ListSubscriptionsByTopic",
      "SNS:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["arn:aws:sns:${var.region}:${var.account_id}*"]

    sid = "SNSPolicy"
  }
}