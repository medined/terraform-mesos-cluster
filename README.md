# terraform-mesos-cluster

## Building a Mesos cluster

- Install Terraform
- cd to the root directory of this project
- run `terraform workspace list` and verify that you are in the development or test workspace (production hasn't been completed)
- create/switch workspaces if needed: 
    - `terraform workspace new development`
    - `terraform workspace select development`

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

## Need to develop counts of instances:

This counts the number of instances of each cluster_group

cat foo.json | jq '.slaves | group_by(.attributes.cluster_group) | .[] | {(.[0].attributes.cluster_group): length}'

This counts the number of instances in each availability zone

cat foo.json | jq '.slaves | group_by(.attributes.availability_zone) | .[] | {(.[0].attributes.availability_zone): length}'

Obtains the name of the group and the cpu counts

cat foo.json | jq '.slaves | group_by(.attributes.cluster_group) | .[] | map({"name": (.attributes.cluster_group),"cpu_count": (.resources.cpus)})'

Continure to sum the cpu counts

cat foo.json | jq '.slaves | group_by(.attributes.cluster_group) | .[] | map({"name": (.attributes.cluster_group),"cpu_count": (.resources.cpus)}) | {(.[0].name): (map(.cpu_count) | add)}'

Gets the key of those

cat foo.json | jq '.slaves | group_by(.attributes.cluster_group) | .[] | map({"name": (.attributes.cluster_group),"cpu_count": (.resources.cpus)}) | {(.[0].name): (map(.cpu_count) | add)} | keys'

Organizes the different group and aggregates available cpu in this case

cat foo2.json | jq '.slaves | group_by(.attributes.cluster_group) | .[] | map({"name": (.attributes.cluster_group),"cpu_count": (.resources.cpus)}) | {"name":(.[0].name), "cpus": (map(.cpu_count) | add)} ' | jq . -s

(base) markthill@marks-mbp tmp % cat /tmp/slaves.json | jq '.slaves | group_by(.attributes.cluster_group) | .[] | map({"name": (.attributes.cluster_group),"cpus": (.resources.cpus),"gpus": (.resources.gpus),"mem": (.resources.mem)}) | {"name":(.[0].name), "cpus": (map(.cpus) | add), "gpus": (map(.gpus) | add), "mem": (map(.mem) | add)} ' | jq . -s | jq '.[].name'
"arroe"
"devops"