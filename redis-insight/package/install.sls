# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}

include:
{%- if grains.kernel == "Linux" %}
  - redis-insight.package.lin_install
{%- elif grains.kernel == "Windows" %}
  - redis-insight.package.win_install
{%- endif %}

Avoid being a null-router (package/install):
  test.nop: []
