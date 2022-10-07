
resource "null_resource" "get_kube_config" {
  depends_on = [
    kubernetes_ingress_v1.contoso-website
  ]
  triggers   = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/get-info.sh ;${path.module}/get-info.sh ${data.terraform_remote_state.aks.outputs.aks_cluster_resourcegroup_name} ${data.terraform_remote_state.aks.outputs.aks_cluster_name}"
    interpreter = ["bash", "-c"]
  }
}

resource "kubernetes_deployment" "contoso-website" {
  metadata {
    name = "contoso-website"
  }
  spec {
    selector {                  # Define the wrapping strategy
      match_labels = {          # Match all pods with the defined labels
        app = "contoso-website" # Labels follow the `name: value` template
      }
    }
    replicas = 2
    template { # This is the template of the pod inside the deployment
      metadata {
        labels = {
          app = "contoso-website"
        }
      }
      spec {
        node_selector = {
          "kubernetes.io/os" = "linux"
        }
        container {
          name  = "contoso-website"
          image = "mcr.microsoft.com/mslearn/samples/contoso-website"
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
            name           = "http"
          }
        }
      }
    }
  }

}


resource "kubernetes_service" "contoso-website" {
  metadata {
    name = "contoso-website"
  }
  spec {
    type = "ClusterIP"
    selector = {
      app = "contoso-website"
    }
    port {
      name        = "http"
      port        = 80
      protocol    = "TCP"
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "contoso-website" {
  metadata {
    name = "contoso-website"
    annotations = {
      "kubernetes.io/ingress.class" = "addon-http-application-routing"
    }
  }
  spec {
    rule {
      host = "contoso.${data.terraform_remote_state.aks.outputs.aks_http_application_routing_zone_name}" 
      http {
        path {
          backend {
            service {
              name = "contoso-website"
              port {
                name = "http"
              }
            }
          }
          path = "/"
          path_type = "Prefix"
        }
      }
    }
  }
}

