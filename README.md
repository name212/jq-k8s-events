# jq-k8s-events
JQ defs for sort, filter and pretty print k8s events.

## include

Save `k8sevents.jq` file to directory, for example `~/lib-jq/k8sevents.jq`
and pass next arguments `-L ~/lib-jq/` to `jq`.

## Examples

```bash
# Only sort
kubectl get events -o json | jq -r -L ~/lib-jq/ 'import "k8sevents" as e; . | e::out_sorted'

# Sort and filter by object name
kubectl get events -o json | jq -r -L ~/lib-jq/ 'import "k8sevents" as e; . | e::by_obj_name("my-node") | e::out_sorted'

# Sort and get only warnings
kubectl get events -o json | jq -r -L ~/lib-jq/ 'import "k8sevents" as e; . | e::warn | e::out_sorted'

# Custom output "${last duration}: ${message}"
kubectl get events -o json | jq -r -L ~/lib-jq/ 'import "k8sevents" as e; . | e::sort_events | map("\(. | e::last_time_duration): \(.message)") | join("\n")'

# All in
kubectl get events -o json | jq -r -L ~/lib-jq/ 'import "k8sevents" as e; . | e::normal | e::by_obj_name("my-node") | e::out_sorted'
```

## Example output
```
  Type:    Normal
  Count:   12
  Last:    8m 3s ago
  Source:  kubelet
  Reason:  SuccessfulMountVolume
  Object:  my-ns/Pod/my-pod
  Message: Success
---
  Type:    Normal
  Count:   1291
  Last:    10m 33s ago
  Source:  kubelet
  Reason:  SuccessfulMountVolume
  Object:  my-ns/Pod/my-pod
  Message: Success
---
  Type:    Warning
  Count:   72
  Last:    10m 33s ago
  Source:  my-controller
  Reason:  Migrated
  Object:  my-ns/Kind/name
  Message: Some Message
```

## Methods

You can use next methods.

- `out_sorted`     - out sorted events with pretty print (with `---` separator and shift to two spaces).

   Result is string.
- `out_sorted_raw` - out sorted events in raw format without separation and shifts.

   Result is string.
- `warn`    - filter only `Warning` events. 

   Result is object with filed `items` that contains array of events.
- `normal` - filter only `Normal` events.

   Result is object with filed `items` that contains array of events.
- `by_type($type)`     - filter with passed type. 

   Kubernetes support only `Warning` and `Normal`events.
   
   Result is object with filed `items` that contains array of events.
- `by_obj_name($name)` - filter with object name without kind.

   Result is object with filed `items` that contains array of events.
- `sort_events` - sort events only. Method add `lastTime` to every event.

   Useful for produce custom output.
   
   Result is array of events.
- `last_time_duration`  - convert `lastTime` field from ISO time to duration.

   Useful for produce custom output.
   
   Result is string.
- `event_happend_count` - returns count of events. If not calculate returns -1.

   Useful for produce custom output.
   
   Result is number.
- `event_happend_count_string` - returns string of count number. If negative returns `unknown`.

   Useful for produce custom output.
   
   Result is string.

## Acknowledgment

[fearphage](https://github.com/fearphage/jq-duration) (licensed with MIT license) for provide
def for converting durations.