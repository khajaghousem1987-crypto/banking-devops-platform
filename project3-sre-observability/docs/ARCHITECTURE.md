# Architecture
Internet -> ALB -> EKS Banking App -> Prometheus -> Grafana

Application/VPC logs -> CloudWatch -> Alarm -> SNS

Application traces -> ADOT/OpenTelemetry -> AWS X-Ray

Project 3 consumes the existing Project 2 VPC/EKS and owns only observability resources.
