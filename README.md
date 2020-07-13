# terraform-mesos-cluster

## Vagrant

**Assumptions**
- have 2 cores available (can configure in Vagrantfile)
- 4GBs or ram free (can configure in Vagrantfile)

Install vagrant locally (instructions for mac but can find equivalent for target OS):

```shell script
brew cask install virtualbox
brew cask install vagrant
```

Check for version:

```shell script
vagrant --version
```

Start vm:

```shell script
cd vagrant/standalone
vagrant up
```

Marathon will be running on http://localhost:8082
