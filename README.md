# jq-k8s-events
JQ defs for sort, filter and pretty print k8s events.

## Examples

```bash
# Only sort
kubectl get events -o json | jq -r 'import "k8sevents" as e; . | e::out_sorted'

# Sort and filter by object name
kubectl get events -o json | jq -r 'import "k8sevents" as e; . e::filter_by_obj_name("my-node") | e::out_sorted'

# Sort and get only warnings
kubectl get events -o json | jq -r 'import "k8sevents" as e; . e::filter_normal | e::out_sorted'

# All in
kubectl get events -o json | jq -r 'import "k8sevents" as e; . e::filter_normal | e::filter_by_obj_name("my-node") | e::out_sorted'
```

## Example output
```
---
  Type: Normal
  Count: 1291
  Time: 1m 48s
  Reason: SuccessfulMountVolume
  Object: Pod/my-pod
  Message: Success
---
  Type: Warning
  Count: 72
  Time: 1m 50s
  Reason: Migrated
  Object: Kind/name
  Message: Some Message
---

```