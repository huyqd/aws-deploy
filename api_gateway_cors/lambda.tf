resource "aws_lambda_function" "listDragons" {
  function_name    = "listDragons"
  role             = aws_iam_role.read-lambda.arn
  handler          = "listDragons.listDragons"
  runtime          = "python3.9"
  filename         = data.archive_file.listDragons.output_path
  source_code_hash = data.archive_file.listDragons.output_base64sha256
}

data "archive_file" "listDragons" {
  type        = "zip"
  source_dir  = "python-dragons-lambda/ListDragons"
  output_path = "python-dragons-lambda/listDragons.zip"
}

resource "aws_lambda_function" "addDragon" {
  function_name    = "addDragon"
  role             = aws_iam_role.read-write-lambda.arn
  handler          = "addDragon.addDragonToFile"
  runtime          = "python3.9"
  filename         = data.archive_file.addDragon.output_path
  source_code_hash = data.archive_file.addDragon.output_base64sha256
}

data "archive_file" "addDragon" {
  type        = "zip"
  source_dir  = "python-dragons-lambda/AddDragon"
  output_path = "python-dragons-lambda/addDragon.zip"
}

resource "aws_lambda_function" "validateDragon" {
  function_name    = "validateDragon"
  role             = aws_iam_role.read-lambda.arn
  handler          = "validateDragon.validate"
  runtime          = "python3.9"
  filename         = data.archive_file.validateDragon.output_path
  source_code_hash = data.archive_file.validateDragon.output_base64sha256
}

data "archive_file" "validateDragon" {
  type        = "zip"
  source_dir  = "python-dragons-lambda/ValidateDragon"
  output_path = "python-dragons-lambda/validateDragon.zip"
}
