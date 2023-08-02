resource "aws_apigatewayv2_api" "MyApiGatewayHTTPApi" {
  name          = "Terraform API Gateway HTTP API to EventBridge"
  protocol_type = "HTTP"
  body = jsonencode(
    {
      "openapi" : "3.0.1",
      "info" : {
        "title" : "API Gateway HTTP API to EventBridge"
      },
      "paths" : {
        "/" : {
          "post" : {
            "responses" : {
              "default" : {
                "description" : "EventBridge response"
              }
            },
            "x-amazon-apigateway-integration" : {
              "integrationSubtype" : "EventBridge-PutEvents",
              "credentials" : var.APIGWRole_arn,
              "requestParameters" : {
                "Detail" : "$request.body.Detail",
                "DetailType" : "MyDetailType",
                "Source" : "demo.apigw"
              },
              "payloadFormatVersion" : "1.0",
              "type" : "aws_proxy",
              "connectionType" : "INTERNET"
            }
          }
        }
      }
  })
}

resource "aws_apigatewayv2_stage" "MyApiGatewayHTTPApiStage" {
  api_id      = aws_apigatewayv2_api.MyApiGatewayHTTPApi.id
  name        = "$default"
  auto_deploy = true
}
