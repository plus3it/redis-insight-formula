# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}

include:
{%- if grains.kernel == "Linux" %}
  - .lin_clean
{%- elif grains.kernel == "Windows" %}
  - .win_clean
{%- endif %}

Avoid being a null-router (package/clean):
  test.nop: []
