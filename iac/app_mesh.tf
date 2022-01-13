resource "aws_appmesh_mesh" "drivers_mesh" {
  name = "drivers-mesh-${local.deploy_stage}"
  tags = local.global_tags
}
