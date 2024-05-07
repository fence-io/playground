# playground

This repository contains fence.io labs.

We use [devbox](https://www.jetify.com/devbox) to provide the best user experience.

# Running labs

Installing devbox is not mandatory, you can also use codespaces or dev containers.

## Installing devbox

Simply run the command below and follow instructions:

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

## Running a lab with devbox

Once devbox is installed, simply enter a lab and run `devbox shell` or `devbox run setup`.

# Available labs

The following labs are available:

| Path | Description | Article |
|---|---|---|
| [kind-cilium](./kind-cilium) | [Setting up Load Balancer Service with Cilium in KinD Cluster] | [Setting up Load Balancer Service with Cilium in KinD Cluster] |
| [kubeval](./resources-validation/kubeval) | [kubeval review] | [kubeval review] |
| [kubeconform](./resources-validation/kubeconform) | [kubeconform review] | [kubeconform review] |

---

[Setting up Load Balancer Service with Cilium in KinD Cluster]: https://fence-io.github.io/website/articles/networking/
[kubeval review]: https://fence-io.github.io/website/articles/k8s-resources-validation/kubeval/
[kubeconform review]: https://fence-io.github.io/website/articles/k8s-resources-validation/kubeconform/
