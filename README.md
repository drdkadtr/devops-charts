# devops-charts

This repo publishes helm packages to this [repo](https://github.com/drdkadtr/devops-helm/).

# Local testing

```
brew install helm
brew install chart-testing

brew tap instrumenta/instrumenta
brew install kubeval

ct lint --all --config ct.yaml
```
