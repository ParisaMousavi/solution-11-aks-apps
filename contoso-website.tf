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
               "cpu" = "100m"
               "memory" = "128Mi"
             }
             limits = {
               "cpu" = "250m"
               "memory" = "256Mi"
             }
           }
           port {
             container_port = 80
             name = "http"
           }
        }
      }
    }
  }

}


resource "null_resource" "validation" {
  depends_on = [module.aks]
  triggers   = { always_run = timestamp() }
  // The order of input values are important for bash
  provisioner "local-exec" {
    command     = "chmod +x ${path.module}/contoso-website.sh ;${path.module}/contoso-website.sh ${data.terraform_remote_state.aks.outputs.aks_cluster_resourcegroup_name} ${data.terraform_remote_state.aks.outputs.aks_cluster_id}"
    interpreter = ["bash", "-c"]
  }
}
