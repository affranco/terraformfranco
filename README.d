Hello everyone 
##This is teh configuration for default on git hub 

/root/eventbridge/
│
├── main.tf
├── outputs.tf
├── variables.tf
│
├── modules/
│   ├── iam/
│   │   ├── iam.tf
│   │   └── outputs.tf
│   │
│   ├── apigateway/
│   │   ├── apigateway.tf
│   │   └── outputs.tf
│   │
│   ├── lambda/
│   │   ├── lambda.tf
│   │   └── outputs.tf
│   │
│   └── cloudwatch/
│       ├── cloudwatch.tf
│       └── outputs.tf
│
├── src/
│   └── LambdaFunction.py    # Aquí está tu archivo Python
│
└── LambdaFunction.zip
