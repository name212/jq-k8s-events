# Copyright 2026
# license that can be found in the LICENSE file.

# duration defs got from https://github.com/fearphage/jq-duration
# with MIT license

def duration($limit; $separator; $default):
  if type != "number" then
    $default
  else
    . as $value
    | [[31536000, "y"], [86400, "d"], [3600, "h"], [60, "m"], [1, "s"]]
    | [label $out | foreach .[] as $item (
        [$value, 1];
        if $limit > 0 and .[1] > $limit then
          break $out
        elif .[0] >= $item[0] then
          [.[0] % $item[0], .[1] + 1] + [(.[0] / $item[0] | floor | tostring) + $item[1]]
        else
          .[0:2]
        end;
        if length > 2 then
          .[2]
        else
          empty
        end)
      ]
    | if length > 0 then join($separator) else "0s" end
  end;

def duration($limit; $separator): duration($limit; $separator; "-");
def duration($limit): duration($limit; " "; "-");
def duration: duration(0; " "; "-");

def event_happend_count:
  if .count != null then 
    .count
  elif .series.count != null then
    .series.count
  else
    -1
  end;

def event_happend_count_string:
  if . < 0 then "unknown" else . | tostring end; 

def last_time_duration:
  .lastTime | .[0:19] +"Z" | fromdateiso8601 as $created | now - $created | floor | duration;

def event_to_msg_strings_array:
  [
      "Type:    \(.type)",
      "Count:   \(. | event_happend_count | event_happend_count_string)",
      "Last:    \(. | last_time_duration) ago",
      "Reason:  \(.reason)",
      "Object:  \(.involvedObject.kind)/\(.involvedObject.name)",
      "Message: \(.message)"
  ];

def events_to_msg_strings_with_tab:
  . | event_to_msg_strings_array | map("  " + .) | join("\n");

def sort_events:
  .items | 
    map(. + (if .lastTimestamp == null then {"lastTime": .eventTime} else {"lastTime": .lastTimestamp} end)) |
    sort_by(.lastTime);

def out_sorted_raw:
  . |
  sort_events |
  map(event_to_msg_strings_array | join("\n")) |
  join("\n");

def out_sorted:
  . |
  sort_events |
  map(events_to_msg_strings_with_tab) |
  join("\n---\n");

def filter_by_type($tp):
  .items | map(select(.type == $tp)) | {"items": .};

def filter_warn:
  . | filter_by_type("Warning");

def filter_normal:
  . | filter_by_type("Normal");

def filter_by_obj_name($name):
  .items | map(select(.involvedObject.name | test($name))) | {"items": .};
