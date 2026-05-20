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
