####### ECR #######
resource "aws_ecr_repository" "gateway_service" {
  name                 = "zdriv-service-gateway"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.global_tags
}

resource "aws_ecr_repository" "driver_location_service" {
  name                 = "zdriv-service-driver-location"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.global_tags
}

resource "aws_ecr_repository" "zombie_detector_service" {
  name                 = "zdriv-service-zombie-detector"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  tags = local.global_tags
}