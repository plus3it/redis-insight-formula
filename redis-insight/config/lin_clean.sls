# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}

Remove REDIS Insight environment profile:
  file.absent:
    - name: {{ redis_insight.config.get(
        'profile_file',
        '/etc/profile.d/redis-insight.sh'
      ) }}

Remove browser policy-file for REDIS Insight:
  file.absent:
    - name: {{ redis_insight.config.browser_policy_dir }}/redis-insight.json

Remove desktop shortcut for REDIS Insight:
  file.absent:
    - name: {{ redis_insight.config.desktop_file }}

Remove global config-file and parent directory:
  file.absent:
    - name: {{ salt['file.dirname'](redis_insight.config.global_cfg) }}
