# -------------------------
# calibre-sync-user for Mac
# -------------------------
resource "aws_iam_user" "mac_user" {
  name = "calibre-sync-user"
  tags = { CreatedBy = "terraform" }
}

data "aws_iam_policy_document" "mac_policy_doc" {
  statement {
    sid = "ListBuckets"
    actions = ["s3:ListBucket"]
    resources = [aws_s3_bucket.library.arn]
  }
  statement {
    sid = "ObjectAccess"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.library.arn}/*"]
  }
}

resource "aws_iam_policy" "mac_policy" {
  name   = "calibre-sync-policy"
  policy = data.aws_iam_policy_document.mac_policy_doc.json
}

resource "aws_iam_user_policy_attachment" "mac_attach" {
  user       = aws_iam_user.mac_user.name
  policy_arn = aws_iam_policy.mac_policy.arn
}

resource "aws_iam_access_key" "mac_keys" {
  user = aws_iam_user.mac_user.name
  # Access key id + secret will be output. Store securely.
}


# ----------------------------------------
# EC2 AssumeRole policy for calibre-server
# ----------------------------------------
data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "calibre-server-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}


# --------------------------------------
# S3 Read-Only policy for calibre-server
# --------------------------------------
data "aws_iam_policy_document" "s3_readonly_for_ec2" {
  statement {
    sid = "AllowReadLibraryBucket"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.library_bucket.arn,
      "${aws_s3_bucket.library_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_readonly_for_ec2" {
  name   = "ec2-s3-readonly"
  policy = data.aws_iam_policy_document.s3_readonly_for_ec2.json
}

resource "aws_iam_role_policy_attachment" "ec2_s3_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_readonly_for_ec2.arn
}


# -----------------------------
# SSM policy for calibre-server
# -----------------------------
resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}