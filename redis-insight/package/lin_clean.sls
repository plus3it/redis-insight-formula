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
    - name: "{{ redis_insight.config.app_dir }}"
    - require:
      - pkg: 'Remove REDIS Insight Package'

Ensure REDIS Insight bin symlink is removed:
  file.absent:
    - name: "/usr/bin/{{ redis_insight.pkg.name }}"
    - require:
      - pkg: 'Remove REDIS Insight Package'

{%- if is_fips %}
Purge REDIS Insight FIPS physical files:
  cmd.run:
    - name: >
        rpm -ql {{ redis_insight.pkg.name }} | sort -r |
        while read -r f; do
        if [ ! -d "$f" ]; then rm -f "$f";
        else rmdir "$f" 2>/dev/null || true; fi;
        done
    - onlyif: 'rpm -q {{ redis_insight.pkg.name }}'
    - require:
      - sls: {{ sls_config_clean }}
    - require_in:
      - pkg: 'Remove REDIS Insight Package'
{%- endif %}

Remove REDIS Insight Package:
  pkg.removed:
    - name: {{ redis_insight.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
