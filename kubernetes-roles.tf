provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }

}


resource "kubernetes_namespace" "online-shopping" {
  metadata {
    name = "online-shopping"
  }
}

resource "kubernetes_cluster_role" "admin_role" {
  metadata {
    name = "admin-role"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["pods", "services", "volumes", "configmap", "secrets"]
  }
}



resource "kubernetes_role" "namespace-viewer" {
  metadata {
    name      = "namespace-viewer"
    namespace = "online-shopping"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "volumes", "configmap", "secrets"]
    verbs      = ["get", "list", "watch", "describe"]
  }
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "describe"]
  }
}


resource "kubernetes_role_binding" "namespace-viewer" {
  metadata {
    name      = "namespace-viewer"
    namespace = "online-shopping"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.namespace-viewer.metadata[0].name
  }
  subject {
    kind      = "User"
    name      = "dev"
    api_group = "rbac.authorization.k8s.io"
  }
}


resource "kubernetes_cluster_role_binding" "example" {
  metadata {
    name = "admin-viewer"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin_role.metadata[0].name
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
}