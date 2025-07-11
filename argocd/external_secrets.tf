

# --------------------------------------------
# External Secrets Operator (ESO)
# --------------------------------------------
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.9.19"
  create_namespace = true

  set = [
    {
      name  = "installCRDs"
      value = "true"
    },
    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.external_secrets_sa_role.arn
    }
  ]
}

resource "null_resource" "wait_for_external_secrets_crds" {
  depends_on = [helm_release.external_secrets]

  provisioner "local-exec" {
    command = <<EOT
for i in {1..30}; do
  echo "Waiting for ESO CRDs..."
  if kubectl get crd clustersecretstores.external-secrets.io >/dev/null 2>&1 && \
     kubectl get crd externalsecrets.external-secrets.io >/dev/null 2>&1; then
    exit 0
  fi
  sleep 5
done
echo "CRDs for external-secrets not found after 150 seconds"
exit 1
EOT
  }
}


# --------------------------------------------
# IRSA: IAM Role
# --------------------------------------------
data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_url_id}:sub"
      values   = ["system:serviceaccount:external-secrets:external-secrets"]
    }
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${var.oidc_url_id}"]
    }
  }
}

resource "aws_iam_role" "external_secrets_sa_role" {
  name               = "external-secrets-irsa"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json
}

resource "aws_iam_role_policy_attachment" "attach_secretsmanager_policy" {
  role       = aws_iam_role.external_secrets_sa_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

#resource "kubernetes_service_account" "external_secrets" {
#  metadata {
#    name      = "external-secrets"
#    namespace = "external-secrets"
#    annotations = {
#      "eks.amazonaws.com/role-arn" = aws_iam_role.external_secrets_sa_role.arn
#    }
#  }
#}

# --------------------------------------------
# ClusterSecretStore
# --------------------------------------------
resource "kubernetes_manifest" "secret_store" {
  depends_on = [
    null_resource.wait_for_external_secrets_crds,
    helm_release.external_secrets
  ]

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "aws-secret-store"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name      = "external-secrets"
                namespace = "external-secrets"
              }
            }
          }
        }
      }
    }
  }
}

## --------------------------------------------
# ExternalSecret: Docker
# --------------------------------------------
resource "kubernetes_manifest" "external_secret_docker" {
  depends_on = [
    kubernetes_manifest.secret_store
  ]

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "regcred"
      namespace = "default"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secret-store"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "regcred"
        creationPolicy = "Owner"
        template = {
          type = "kubernetes.io/dockerconfigjson"
          data = {
            ".dockerconfigjson" = <<EOT
{
  "auths": {
    "https://index.docker.io/v1/": {
      "username": "{{ .username }}",
      "password": "{{ .password }}",
      "auth": "{{ printf "%s:%s" .username .password | b64enc }}"
    }
  }
}
EOT
          }
        }
      }
      data = [
        {
          secretKey = "username"
          remoteRef = {
            key      = "devops/danit/docker"
            property = "username"
          }
        },
        {
          secretKey = "password"
          remoteRef = {
            key      = "devops/danit/docker"
            property = "password"
          }
        }
      ]
    }
  }
}

# --------------------------------------------
# ExternalSecret: GitHub
# --------------------------------------------
resource "kubernetes_manifest" "external_secret_github" {
  depends_on = [
  kubernetes_manifest.secret_store
]

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "github-auth"
      namespace = "argocd"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secret-store"
        kind = "ClusterSecretStore"
      }
      target = {
        name           = "github-auth"
        creationPolicy = "Owner"
      }
      data = [
        {
          secretKey = "username"
          remoteRef = {
            key      = "devops/danit/github"
            property = "username"
          }
        },
        {
          secretKey = "password"
          remoteRef = {
            key      = "devops/danit/github"
            property = "token"
          }
        }
      ]
    }
  }
}