# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}

include:
{%- if grains.kernel == "Linux" %}
  - redis-insight.config.lin_clean
{%- elif grains.kernel == "Windows" %}
  - redis-insight.config.win_clean
{%- endif %}

Avoid being a null-router (config/clean) - REDIS Insight:
  test.nop: []
