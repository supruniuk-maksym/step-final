

output "cluster_name" {
  value = aws_eks_cluster.danit.name
}

output "region" {
  value = var.region
}

output "oidc_url_id" {
  value = replace(
    aws_eks_cluster.danit.identity[0].oidc[0].issuer,
    "https://oidc.eks.${var.region}.amazonaws.com/id/",
    ""
  )
}


# output "account_id" {
#   value = data.aws_caller_identity.current.account_id
# }