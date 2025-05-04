resource "aws_iam_role" "s3_readonly_ec2" {
  name = "lab-s3-readonly-ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "lab-s3-readonly-ec2"
  }
}

resource "aws_iam_policy" "s3_readonly_specific" {
  name = "lab-s3-readonly-specific"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        "arn:aws:s3:::lab-data-88184046",
        "arn:aws:s3:::lab-data-88184046/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_readonly" {
  role       = aws_iam_role.s3_readonly_ec2.name
  policy_arn = aws_iam_policy.s3_readonly_specific.arn
}

resource "aws_iam_instance_profile" "s3_readonly_profile" {
  name = "lab-s3-readonly-profile"
  role = aws_iam_role.s3_readonly_ec2.name
}
