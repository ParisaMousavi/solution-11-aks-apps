resource "kubernetes_deployment" "helloworld" {
  metadata {
    name = "hellowoeld"
  }
  spec {
    selector {
      match_labels = {
        "app" = "helloworld"
      }
    }
    replicas = 2
    template {
      metadata {
        labels = {
          "app" = "helloworld"
        }
      }
      spec {
        container {
          name = "helloworld"
          image = "karthequian/helloworld:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }

}