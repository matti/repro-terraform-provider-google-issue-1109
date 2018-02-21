Begin:

```
➜  repro-terraform-provider-google-issue-1109 git:(master) ✗ terraform apply -auto-approve

-- apply --
google_compute_instance_template.test[0]: Refreshing state... (ID: terraform-20180221084010747800000001)
google_compute_instance_template.test[2]: Refreshing state... (ID: terraform-20180221084010750100000003)
google_compute_instance_template.test[1]: Refreshing state... (ID: terraform-20180221084010750000000002)
data.google_compute_zones.all: Refreshing state...
google_compute_instance_group_manager.test[2]: Refreshing state... (ID: test-3)
google_compute_instance_group_manager.test[1]: Refreshing state... (ID: test-2)
google_compute_instance_group_manager.test[0]: Refreshing state... (ID: test-1)
data.google_compute_instance_group.all[2]: Refreshing state...
data.google_compute_instance_group.all[1]: Refreshing state...
data.google_compute_instance_group.all[0]: Refreshing state...
google_compute_target_pool.default: Refreshing state... (ID: instance-pool)

Apply complete! Resources: 0 added, 0 changed, 0 destroyed.
```

Now delete one instance so that it's recreated by the instance group manager and apply while it's recreating:

```
➜  repro-terraform-provider-google-issue-1109 git:(master) ✗ terraform apply -auto-approve

-- apply --
google_compute_instance_template.test[1]: Refreshing state... (ID: terraform-20180221084010750000000002)
google_compute_instance_template.test[0]: Refreshing state... (ID: terraform-20180221084010747800000001)
google_compute_instance_template.test[2]: Refreshing state... (ID: terraform-20180221084010750100000003)
data.google_compute_zones.all: Refreshing state...
google_compute_instance_group_manager.test[0]: Refreshing state... (ID: test-1)
google_compute_instance_group_manager.test[1]: Refreshing state... (ID: test-2)
google_compute_instance_group_manager.test[2]: Refreshing state... (ID: test-3)
data.google_compute_instance_group.all[1]: Refreshing state...
data.google_compute_instance_group.all[2]: Refreshing state...
data.google_compute_instance_group.all[0]: Refreshing state...
google_compute_target_pool.default: Refreshing state... (ID: instance-pool)
google_compute_target_pool.default: Modifying... (ID: instance-pool)
  instances.#: "2" => "3"
  instances.0: "europe-west1-c/test-2-mp5w" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-b/instances/test-1-pxj8"
  instances.1: "europe-west1-d/test-3-xv25" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-c/instances/test-2-mp5w"
  instances.2: "" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-d/instances/test-3-xv25"
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 10s elapsed)
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 20s elapsed)
google_compute_target_pool.default: Modifications complete after 22s (ID: instance-pool)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.

```

Now it's gone. Then being recreated:

```
➜  repro-terraform-provider-google-issue-1109 git:(master) ✗ terraform apply -auto-approve

-- apply --
google_compute_instance_template.test[2]: Refreshing state... (ID: terraform-20180221084010750100000003)
google_compute_instance_template.test[1]: Refreshing state... (ID: terraform-20180221084010750000000002)
google_compute_instance_template.test[0]: Refreshing state... (ID: terraform-20180221084010747800000001)
data.google_compute_zones.all: Refreshing state...
google_compute_instance_group_manager.test[2]: Refreshing state... (ID: test-3)
google_compute_instance_group_manager.test[0]: Refreshing state... (ID: test-1)
google_compute_instance_group_manager.test[1]: Refreshing state... (ID: test-2)
data.google_compute_instance_group.all[0]: Refreshing state...
data.google_compute_instance_group.all[1]: Refreshing state...
data.google_compute_instance_group.all[2]: Refreshing state...
google_compute_target_pool.default: Refreshing state... (ID: instance-pool)
google_compute_target_pool.default: Modifying... (ID: instance-pool)
  instances.0: "europe-west1-c/test-2-mp5w" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-b/instances/test-1-pxj8"
  instances.1: "europe-west1-d/test-3-xv25" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-c/instances/test-2-mp5w"
  instances.2: "europe-west1-b/test-1-pxj8" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-d/instances/test-3-xv25"
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 10s elapsed)
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 20s elapsed)
google_compute_target_pool.default: Modifications complete after 23s (ID: instance-pool)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```


And now it will always change:
```
➜  repro-terraform-provider-google-issue-1109 git:(master) ✗ terraform apply -auto-approve

-- apply --
google_compute_instance_template.test[0]: Refreshing state... (ID: terraform-20180221084010747800000001)
google_compute_instance_template.test[2]: Refreshing state... (ID: terraform-20180221084010750100000003)
google_compute_instance_template.test[1]: Refreshing state... (ID: terraform-20180221084010750000000002)
data.google_compute_zones.all: Refreshing state...
google_compute_instance_group_manager.test[1]: Refreshing state... (ID: test-2)
google_compute_instance_group_manager.test[0]: Refreshing state... (ID: test-1)
google_compute_instance_group_manager.test[2]: Refreshing state... (ID: test-3)
data.google_compute_instance_group.all[2]: Refreshing state...
data.google_compute_instance_group.all[1]: Refreshing state...
data.google_compute_instance_group.all[0]: Refreshing state...
google_compute_target_pool.default: Refreshing state... (ID: instance-pool)
google_compute_target_pool.default: Modifying... (ID: instance-pool)
  instances.0: "europe-west1-c/test-2-mp5w" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-b/instances/test-1-pxj8"
  instances.1: "europe-west1-d/test-3-xv25" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-c/instances/test-2-mp5w"
  instances.2: "europe-west1-b/test-1-pxj8" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-d/instances/test-3-xv25"
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 10s elapsed)
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 20s elapsed)
google_compute_target_pool.default: Modifications complete after 22s (ID: instance-pool)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
➜  repro-terraform-provider-google-issue-1109 git:(master) ✗ terraform apply -auto-approve

-- apply --
google_compute_instance_template.test[1]: Refreshing state... (ID: terraform-20180221084010750000000002)
google_compute_instance_template.test[2]: Refreshing state... (ID: terraform-20180221084010750100000003)
google_compute_instance_template.test[0]: Refreshing state... (ID: terraform-20180221084010747800000001)
data.google_compute_zones.all: Refreshing state...
google_compute_instance_group_manager.test[2]: Refreshing state... (ID: test-3)
google_compute_instance_group_manager.test[0]: Refreshing state... (ID: test-1)
google_compute_instance_group_manager.test[1]: Refreshing state... (ID: test-2)
data.google_compute_instance_group.all[0]: Refreshing state...
data.google_compute_instance_group.all[2]: Refreshing state...
data.google_compute_instance_group.all[1]: Refreshing state...
google_compute_target_pool.default: Refreshing state... (ID: instance-pool)
google_compute_target_pool.default: Modifying... (ID: instance-pool)
  instances.0: "europe-west1-c/test-2-mp5w" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-b/instances/test-1-pxj8"
  instances.1: "europe-west1-d/test-3-xv25" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-c/instances/test-2-mp5w"
  instances.2: "europe-west1-b/test-1-pxj8" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-d/instances/test-3-xv25"
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 10s elapsed)
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 20s elapsed)
google_compute_target_pool.default: Modifications complete after 22s (ID: instance-pool)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
➜  repro-terraform-provider-google-issue-1109 git:(master) ✗ terraform apply -auto-approve

-- apply --
google_compute_instance_template.test[2]: Refreshing state... (ID: terraform-20180221084010750100000003)
google_compute_instance_template.test[1]: Refreshing state... (ID: terraform-20180221084010750000000002)
google_compute_instance_template.test[0]: Refreshing state... (ID: terraform-20180221084010747800000001)
data.google_compute_zones.all: Refreshing state...
google_compute_instance_group_manager.test[1]: Refreshing state... (ID: test-2)
google_compute_instance_group_manager.test[2]: Refreshing state... (ID: test-3)
google_compute_instance_group_manager.test[0]: Refreshing state... (ID: test-1)
data.google_compute_instance_group.all[0]: Refreshing state...
data.google_compute_instance_group.all[1]: Refreshing state...
data.google_compute_instance_group.all[2]: Refreshing state...
google_compute_target_pool.default: Refreshing state... (ID: instance-pool)
google_compute_target_pool.default: Modifying... (ID: instance-pool)
  instances.0: "europe-west1-c/test-2-mp5w" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-b/instances/test-1-pxj8"
  instances.1: "europe-west1-d/test-3-xv25" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-c/instances/test-2-mp5w"
  instances.2: "europe-west1-b/test-1-pxj8" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-d/instances/test-3-xv25"
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 10s elapsed)
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 20s elapsed)
google_compute_target_pool.default: Modifications complete after 21s (ID: instance-pool)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
➜  repro-terraform-provider-google-issue-1109 git:(master) ✗ terraform apply -auto-approve

-- apply --
google_compute_instance_template.test[2]: Refreshing state... (ID: terraform-20180221084010750100000003)
google_compute_instance_template.test[0]: Refreshing state... (ID: terraform-20180221084010747800000001)
google_compute_instance_template.test[1]: Refreshing state... (ID: terraform-20180221084010750000000002)
data.google_compute_zones.all: Refreshing state...
google_compute_instance_group_manager.test[0]: Refreshing state... (ID: test-1)
google_compute_instance_group_manager.test[1]: Refreshing state... (ID: test-2)
google_compute_instance_group_manager.test[2]: Refreshing state... (ID: test-3)
data.google_compute_instance_group.all[1]: Refreshing state...
data.google_compute_instance_group.all[0]: Refreshing state...
data.google_compute_instance_group.all[2]: Refreshing state...
google_compute_target_pool.default: Refreshing state... (ID: instance-pool)
google_compute_target_pool.default: Modifying... (ID: instance-pool)
  instances.0: "europe-west1-c/test-2-mp5w" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-b/instances/test-1-pxj8"
  instances.1: "europe-west1-d/test-3-xv25" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-c/instances/test-2-mp5w"
  instances.2: "europe-west1-b/test-1-pxj8" => "https://www.googleapis.com/compute/v1/projects/ag-dolan/zones/europe-west1-d/instances/test-3-xv25"
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 10s elapsed)
google_compute_target_pool.default: Still modifying... (ID: instance-pool, 20s elapsed)
google_compute_target_pool.default: Modifications complete after 23s (ID: instance-pool)

Apply complete! Resources: 0 added, 1 changed, 0 destroyed.
```
