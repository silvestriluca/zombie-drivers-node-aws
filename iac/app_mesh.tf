resource "aws_appmesh_mesh" "drivers_mesh" {
  name = "drivers-mesh-${local.deploy_stage}"
  tags = merge(local.global_tags, { stage = local.deploy_stage })
}