# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}

{% set is_fips = False %}
{% if salt['file.file_exists']('/proc/sys/crypto/fips_enabled') %}
  {% set is_fips = (
      salt['file.read'](
        '/proc/sys/crypto/fips_enabled'
      ) | trim == '1'
    )
  %}
{% endif %}

include:
  - {{ sls_config_clean }}

Ensure REDIS Insight app-directory is removed:
  file.absent:
    - name: '{{ redis_insight.config.app_dir }}'
    - require:
      - cmd: 'Uninstall REDIS Insight'

Uninstall REDIS Insight:
  cmd.run:
    - name: >-
        Start-Process -FilePath
        '{{ redis_insight.config.app_dir }}\Uninstall Redis Insight.exe'
        -ArgumentList '/S', '/AllUsers'
        -Wait
    - onlyif: >-
        powershell.exe -ExecutionPolicy Bypass -NoProfile -Command
        "if (Test-Path '{{ redis_insight.config.app_dir }}\Uninstall Redis
        Insight.exe') { exit 0 } else { exit 1 }"
    - require:
      - sls: {{ sls_config_clean }}
    - shell: powershell
