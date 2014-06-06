# Woodchuck

Eat log files, excrete into data store.

## Configuration

### Files to watch

```json
{
  "fission": {
    "woodchuck": {
      "paths": [
        "/var/log/syslog"
      ]
    }
  }
}
```

### Apply callback filters

```json
{
  "fission": {
    "woodchuck": {
      "filters": [
        "my_source_filter",
        "my_other_source_filter"
      ]
    }
  }
}
```

### Send factory payloads to custom handler

```json
{
  "fission": {
    "woodchuck": {
      "processor": "my_custom_source_handler"
    }
  }
}
```

### Define node name (defaults to dns name)

```json
{
  "fission": {
    "woodchuck": {
      "node_name": "fubar.example.com"
    }
  }
}
```