
resource "kubernetes_deployment" "azure-vote-back" {
  metadata {
    name = "azure-vote-back"
  }
  spec {
    selector {                  # Define the wrapping strategy
      match_labels = {          # Match all pods with the defined labels
        app = "azure-vote-back" # Labels follow the `name: value` template
      }
    }
    replicas = 2
    template { # This is the template of the pod inside the deployment
      metadata {
        labels = {
          app = "azure-vote-back"
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        container {
          name  = "azure-vote-back"
          image = "mcr.microsoft.com/oss/bitnami/redis:6.0.8"
          env {
            name = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }
          resources {
            requests = {
              "cpu"    = "100m"
              "memory" = "128Mi"
            }
            limits = {
              "cpu"    = "250m"
              "memory" = "256Mi"
            }
          }
          port {
            container_port = 6379
            name           = "redis"
          }
        }
      }
    }
  }

}


resource "kubernetes_service" "azure-vote-back" {
  metadata {
    name = "azure-vote-back"
  }
  spec {
    port {
      port = 6379
    }
    selector = {
        app = "azure-vote-back"
    }
  }
}


resource "kubernetes_deployment" "azure-vote-front" {
  metadata {
    name = "azure-vote-front"
  }
  spec {
    selector {                  # Define the wrapping strategy
      match_labels = {          # Match all pods with the defined labels
        app = "azure-vote-front" # Labels follow the `name: value` template
      }
    }
    replicas = 2
    template { # This is the template of the pod inside the deployment
      metadata {
        labels = {
          app = "azure-vote-front"
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        container {
          name  = "azure-vote-front"
          image = "mcr.microsoft.com/azuredocs/azure-vote-front:v1"
          resources {
            requests = {
              "cpu"    = "100m"
              "memory" = "128Mi"
            }
            limits = {
              "cpu"    = "250m"
              "memory" = "256Mi"
            }
          }
          port {
            container_port = 80
          }
          env {
            name = "REDIS"
            value = "azure-vote-back"
          }
        }
      }
    }
  }

}

resource "kubernetes_service" "azure-vote-front" {
  metadata {
    name = "azure-vote-front"
  }
  spec {
    type = "LoadBalancer"
    port {
      port = 80
    }
    selector = {
        app = "azure-vote-front"
    }
  }
}


resource "null_resource" "get_info" {
  depends_on = [
    kubernetes_service.azure-vote-front
  ]
  triggers   = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/get-info.sh ;${path.module}/get-info.sh ${data.terraform_remote_state.aks.outputs.aks_cluster_resourcegroup_name} ${data.terraform_remote_state.aks.outputs.aks_cluster_name}"
    interpreter = ["bash", "-c"]
  }
}