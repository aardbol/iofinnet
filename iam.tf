resource "aws_iam_group" "devops" {
  name = "devops"
}

resource "aws_iam_user" "leo" {
  name = "leo"

}

resource "aws_iam_group_membership" "leo_devops" {
  name = "leo_devops"
  users = [aws_iam_user.leo.name]
  group = aws_iam_group.devops.name
}

resource "aws_iam_user_policy_attachment" "leo_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  user       = aws_iam_user.leo.name
}
