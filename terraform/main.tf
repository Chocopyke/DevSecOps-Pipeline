module "vpc" {
  source = "./modules/vpc"
  name   = var.proj_name
}

module "alb" {
  source               = "./modules/alb"
  alb_name             = "dacn_alb"
  vpc_id               = module.vpc.vpc_id
  security_groups      = [module.vpc.dacn_sg_id]
  internet_alb_subnets = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  internal_alb_subnets = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
}

module "route53_private_hosted_zone" {
  source = "./modules/route53"
  dns_name = "backend.local"
  vpc_id = module.vpc.vpc_id
  alias_name = module.alb.internal_alb_dns_name
  alias_zone_id = module.alb.internal_alb_zone_id
  evaluate_target_health = false
}

# module "ecr" {
#   source          = "./modules/ecr"
#   repository_name = "lamlt-sonvt"
# }

module "ecs" {
  source = "./modules/ecs"
  cluster_name = "dacn-cluster"
  subnet_id = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  security_group_id = [module.vpc.dacn_sg_id]

  alb_target_group_fe_arn = module.alb.front_end_target_group_arn
  alb_target_group_cs_arn = module.alb.cart_service_target_group_arn
  alb_target_group_ps_arn = module.alb.product_service_target_group_arn
  alb_target_group_us_arn = module.alb.user_service_target_group_arn
}