redis-insight:
  lookup:
    pkg:
      {%- if grains.os_family == "RedHat" %}
      name: redisinsight
      download_uri: ''
      download_sig: ''
      {%- endif %}
