project = "hashitalk-deploy-aws"

app "hello-app-aws" {
  runner {
    profile = "kubernetes-aws"
  }

  build {
    workspace = "susan-local"
    use "docker" {}
    registry {
      use "docker" {
        image = var.image
        // returns a humanized version of the git hash, taking into account tags and changes
        tag = gitrefpretty()
        // Credentials for authentication to push to docker registry
        auth {
          username = var.username
          password = var.password
        }
      }
    }
  }

  deploy {
    workspace = "susan-local"
    use "docker" {
      service_port = 3000
      static_environment = {
        PLATFORM = "docker (dev)"
      }
    }

    workspace = "default"
    use "kubernetes" {
      service_port = 5300
      namespace = "default"
    }
  }

  release {
    use "kubernetes" {
      port          = 5300
    }
  }
}

variable "image" {
  type = string
  default = "sdav9375/hashitalk-deploy"
}
variable "username" {
  type = string
  default = "sdav9375"
}
variable "password" {
  type = string
  env = ["DOCKER_PWD"]
  sensitive = true
}