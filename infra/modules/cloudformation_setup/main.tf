# Cloudformation setup
locals {
  current_desired_count = "${min(max(0, var.asg_min), var.asg_max)}"
  instance_role_as_list = ["${var.web_instance_role_name}"]
  instance_role_name    = "${element(concat(aws_iam_instance_profile.profile.*.name, local.instance_role_as_list), 0)}"
  desired_adjusted      = "${var.spot_price == "" ? local.current_desired_count : local.current_desired_count + var.update_batch}"
  desired_count         = "${var.enable_rolling_update == "true" ? local.desired_adjusted : local.current_desired_count}"

  replacing_update = <<EOF
          AutoScalingReplacingUpdate:
            WillReplace: true
  EOF

  rolling_update = <<EOF
          AutoScalingRollingUpdate:
            MaxBatchSize: ${var.update_batch}
            MinInstancesInService: ${var.spot_price == "" ? local.current_desired_count : 0}
            MinSuccessfulInstancesPercent: 80
            PauseTime: PT15M
            SuspendProcesses:
              - HealthCheck
              - ReplaceUnhealthy
              - AZRebalance
              - AlarmNotification
              - ScheduledActions
            WaitOnResourceSignals: true
  EOF

  market_options_str = <<EOF
            InstanceMarketOptions:
              SpotOptions:
                SpotInstanceType: one-time
                InstanceInterruptionBehavior: terminate
                MaxPrice: ${var.spot_price}
              MarketType: spot
  EOF

  loadbalancers_str = <<EOF
          LoadBalancerNames: ${jsonencode("${list(var.web_elb_name)}")}
  EOF

  update_policy = "${var.enable_rolling_update == "true" ? local.rolling_update : local.replacing_update}"
  market_options = "${var.spot_price != "" ? local.market_options_str : format("#")}"
  loadbalancers = "${var.attach_loadbalancers == "true" ? local.loadbalancers_str : format("#")}"
}

resource "aws_cloudformation_stack" "web-cloudformation-asg" {
  name = "${var.stack_prefix}-stack"

  template_body = <<EOF
    Resources:
      WebLaunchTemplate:
        Type: "AWS::EC2::LaunchTemplate"
        Properties:
          LaunchTemplateData:
            UserData: ${base64encode(data.template_file.user_data.rendered)}
            IamInstanceProfile:
              Name: ${local.instance_role_name}
            SecurityGroupIds:
              - ${aws_security_group.web_instance_sg.id}
            KeyName: ${var.key_name}
            ImageId: ${lookup(var.aws_amis, var.aws_region)}
            InstanceType: ${var.instance_type}
${local.market_options}
      POL:
        Type: "AWS::AutoScaling::ScalingPolicy"
        Properties:
          AutoScalingGroupName: !Ref WebASG
          PolicyType: TargetTrackingScaling
          TargetTrackingConfiguration:
            PredefinedMetricSpecification:
              PredefinedMetricType: ASGAverageCPUUtilization
            TargetValue: ${var.cpu_util_target}
      WebASG:
        Type: "AWS::AutoScaling::AutoScalingGroup"
        Properties:
          # AutoScalingGroupName: "${var.stack_prefix}-asg"
          VPCZoneIdentifier: ${jsonencode(var.vpc_zone_identifier)}
          LaunchTemplate:
            LaunchTemplateId: !Ref WebLaunchTemplate
            Version: !GetAtt WebLaunchTemplate.LatestVersionNumber
          MinSize: ${var.asg_min}
          MaxSize: ${var.asg_max}
          HealthCheckType: EC2
          TerminationPolicies:
            - OldestLaunchConfiguration
            - OldestInstance
            - Default
${local.loadbalancers}
          Tags:
            - Key: env
              Value: "${var.my_env}"
              PropagateAtLaunch: true
            - Key: stack_prefix
              Value: "${var.stack_prefix}"
              PropagateAtLaunch: true

        CreationPolicy:
          AutoScalingCreationPolicy:
            MinSuccessfulInstancesPercent: 80
          ResourceSignal:
            Count: ${local.desired_count}
            Timeout: PT15M
        UpdatePolicy:
        # Ignore differences in group size properties caused by scheduled actions
          AutoScalingScheduledAction:
            IgnoreUnmodifiedGroupSizeProperties: true
${local.update_policy}
        DeletionPolicy: Delete
  EOF
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars = {
    my_env             = "${var.my_env}"
    stack_prefix       = "${var.stack_prefix}"
    health_check_port  = "${var.health_check_port}"
    health_check_path  = "${var.health_check_path}"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "role-policy" {
  //TODO: remove after we let freeipa manage the dns of the instances
  statement {
    actions = [
      "route53:ListTrafficPolicyInstances",
      "route53:GetTrafficPolicyInstanceCount",
      "route53:GetChange",
      "route53:ListTrafficPolicyVersions",
      "route53:TestDNSAnswer",
      "route53:GetHostedZone",
      "route53:GetHealthCheck",
      "route53:ListHostedZonesByName",
      "route53:ListQueryLoggingConfigs",
      "route53:GetCheckerIpRanges",
      "route53:ListTrafficPolicies",
      "route53:ListResourceRecordSets",
      "route53:ListGeoLocations",
      "route53:GetTrafficPolicyInstance",
      "route53:GetHostedZoneCount",
      "route53:GetHealthCheckCount",
      "route53:GetQueryLoggingConfig",
      "route53:ListReusableDelegationSets",
      "route53:GetHealthCheckLastFailureReason",
      "route53:GetHealthCheckStatus",
      "route53:ListTrafficPolicyInstancesByHostedZone",
      "route53:ListHostedZones",
      "route53:ListVPCAssociationAuthorizations",
      "route53:GetReusableDelegationSetLimit",
      "route53:ChangeResourceRecordSets",
      "route53:GetReusableDelegationSet",
      "route53:ListTagsForResource",
      "route53:ListTagsForResources",
      "route53:GetAccountLimit",
      "route53:ListTrafficPolicyInstancesByPolicy",
      "route53:ListHealthChecks",
      "route53:GetGeoLocation",
      "route53:GetHostedZoneLimit",
      "route53:GetTrafficPolicy",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",
    ]

    resources = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.my_env}/*"]
  }

  statement {
    actions = [
      "elasticloadbalancing:DescribeInstanceHealth",
      "elasticloadbalancing:DescribeTargetHealth",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name_prefix = "web-ec2-policy"
  policy      = "${data.aws_iam_policy_document.role-policy.json}"
}

resource "aws_iam_role" "role" {
  name_prefix           = "web-ec2-role"
  force_detach_policies = true

  assume_role_policy = <<EOF
{
"Statement": [
{
    "Sid": "",
    "Effect": "Allow",
    "Principal": {
        "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
}
],
"Version": "2012-10-17"
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach" {
  count      = "${var.web_instance_role_name == "" ? 1 : 0}"
  role       = "${aws_iam_role.role.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

resource "aws_iam_instance_profile" "profile" {
  count       = "${var.web_instance_role_name == "" ? 1 : 0}"
  name_prefix = "web-ec2-profile"
  role        = "${aws_iam_role.role.name}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "web_instance_sg" {
  name        = "web_${var.stack_prefix}_sg"
  description = "Used in the terraform"
  vpc_id      = "${var.vpc_id}"

  # ssh access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.developer_cidr_blocks}"
  }

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"

    security_groups = [
      "${var.web_elb_sg_id}",
    ]
  }

  # allow communication between nodes
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    self = true
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
