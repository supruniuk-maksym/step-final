
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# --------------------------------------------
# Встановлення ArgoCD через Helm
# --------------------------------------------
resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.51.6"
  create_namespace = true

  set = [
    {
      name  = "crds.install"
      value = "true"
    },
    {
      name  = "server.ingress.enabled"
      value = "true"
    },
    {
      name  = "server.ingress.hostname"
      value = "argocd.student1.devops7.dev.eugenich.com"
    },
    {
      name  = "server.ingress.annotations.kubernetes\\.io/ingress\\.class"
      value = "nginx"
    },
    {
      name  = "server.service.type"
      value = "ClusterIP"
    }
  ]
}

# --------------------------------------------
# Очікування на встановлення CRD Application
# --------------------------------------------
resource "null_resource" "wait_for_argocd_crds" {
  depends_on = [helm_release.argocd]

  provisioner "local-exec" {
    command = <<EOT
for i in {1..30}; do
  echo "Waiting for ArgoCD CRDs..."
  kubectl get crd applications.argoproj.io >/dev/null 2>&1 && exit 0
  sleep 5
done
echo "CRDs for ArgoCD not found after 150 seconds"
exit 1
EOT
  }
}

# --------------------------------------------
# ArgoCD Application
# --------------------------------------------
resource "kubernetes_manifest" "argocd_application" {
  depends_on = [null_resource.wait_for_argocd_crds]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "my-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/supruniuk-maksym/step-final" 
        targetRevision = "main"
        path           = "k8s"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }

      syncPolicy = {
        automated = {
          prune     = true
          selfHeal  = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}