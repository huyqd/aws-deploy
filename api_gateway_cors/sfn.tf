resource "aws_sfn_state_machine" "aws-deploy" {
  name     = local.project_name
  role_arn = aws_iam_role.sfn_role.arn

  definition = <<EOF
  {
  "Comment": "Dragon will be validated. If validation fails, a failure message will be sent. If the dragon is valid, it will be added to the data and a success message will be sent.",
  "StartAt": "ValidateDragon",
  "States": {
    "ValidateDragon": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.validateDragon.arn}",
      "Catch": [
        {
          "ErrorEquals": [
            "DragonValidationException"
          ],
          "Next": "AlertDragonValidationFailure",
          "ResultPath": null
        },
        {
          "ErrorEquals": [
            "States.ALL"
          ],
          "Next": "CatchAllFailure"
        }
      ],
      "Next": "AddDragon",
      "ResultPath": null
    },
    "AlertDragonValidationFailure": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "The dragon you reported failed validation and was not added.",
        "PhoneNumber.$": "$.reportingPhoneNumber"
      },
      "End": true
    },
    "CatchAllFailure": {
      "Type": "Fail",
      "Cause": "Something unknown went wrong."
    },
    "AddDragon": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.addDragon.arn}",
      "Next": "ConfirmationRequired",
      "ResultPath": null
    },
    "ConfirmationRequired": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.confirmationRequired",
          "BooleanEquals": true,
          "Next": "AlertAddDragonSuccess"
        },
        {
          "Variable": "$.confirmationRequired",
          "BooleanEquals": false,
          "Next": "NoAlertAddDragonSuccess"
        }
      ],
      "Default": "CatchAllFailure"
    },
    "AlertAddDragonSuccess": {
      "Type": "Task",
      "Resource": "arn:aws:states:::sns:publish",
      "Parameters": {
        "Message": "The dragon you reported has been added!",
        "PhoneNumber.$": "$.reportingPhoneNumber"
      },
      "End": true
    },
    "NoAlertAddDragonSuccess": {
      "Type": "Succeed"
    }
  }
}
  EOF
}
