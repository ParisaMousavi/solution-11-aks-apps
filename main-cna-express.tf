resource "kubernetes_deployment" "cna-express" {
  metadata {
    name = "cna-express"
  }
  spec {
    selector {
      match_labels = {
        "app" = "cna-express"
      }
    }
    template {
      metadata {
        labels = {
          "app" = "cna-express"
        }
      }
      spec {
        container {
          name  = "expressimage"
          image = "projncrappdevgwc.azurecr.io/expressimage"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# resource "kubernetes_service" "cna-express" {
#   metadata {
#     name = "cna-express"
#   }
#   spec {
#     type = "ClusterIP"
#     selector = {
#       "app" = "cna-express"
#     }
#     port {
#       name = "http"
#       port = 80
#       target_port = 4000
#       protocol = "tcp"
#     }
#   }
# }
