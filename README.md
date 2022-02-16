# devops-charts

This repo publishes helm packages to this [repo](https://github.com/drdkadtr/devops-helm/).

# Local testing

## ct
```
brew install helm
brew install chart-testing
ct lint --all --config ct.yaml
```

## kubeval
```
brew tap instrumenta/instrumenta
brew install kubeval
```
