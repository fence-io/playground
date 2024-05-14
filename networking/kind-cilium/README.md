# kind-cilium lab

This lab accompanies the article [Setting up Load Balancer Service with Cilium in KinD Cluster](https://fence-io.github.io/website/articles/networking/setting-up-load-balancer-service-with-cilium-in-kind-cluster/).

## Running on Linux

If you are running on Linux you can run the lab immediately.

## Running on macOS

If you are running on macOS you will need to install https://github.com/chipmk/docker-mac-net-connect.

```bash
brew install chipmk/tap/docker-mac-net-connect
sudo brew services start chipmk/tap/docker-mac-net-connect
```

# Execute lab

To execute this lab with [devbox](https://www.jetify.com/devbox) run `devbox run setup`.

Run `devbox run shutdown` to clean up resources.
