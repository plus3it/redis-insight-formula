# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Ensure Default User config-directory exists:
  file.directory:
    - name: '{{ redis_insight.config.default_user_dir }}'
    - makedirs: True

Manage global config-file for Default User:
  file.managed:
    - context:
        redis_insight: {{ redis_insight | json }}
    - name: '{{ redis_insight.config.default_user_dir }}\config.json'
    - require:
      - file: 'Ensure Default User config-directory exists'
    - source: {{ files_switch(
        ['config.json.jinja'],
        lookup='redis-insight-config-file-managed'
      ) }}
    - template: jinja
