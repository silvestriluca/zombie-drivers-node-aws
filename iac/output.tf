output "ecr_repo_gateway" {
  description = "URL of gateway service ECR repository"
  value = aws_ecr_repository.gateway_service.repository_url
}

output "ecr_repo_driver_location" {
  description = "URL of driver-location service ECR repository"
  value = aws_ecr_repository.driver_location_service.repository_url
}

output "ecr_repo_zombie_detector" {
  description = "URL of driver-location service ECR repository"
  value = aws_ecr_repository.zombie_detector_service.repository_url
}