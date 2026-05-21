# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}
{%- set browser_policies = redis_insight.config.get('browser_policies', {}) %}

{%- for policy, val in browser_policies.items() %}
Remove Browser Policy - {{ policy }}:
  reg.absent:
    - name: 'HKLM\SOFTWARE\Policies\Google\Chrome'
    - vname: '{{ policy }}'
{%- endfor %}

Remove Default User config-directory:
  file.absent:
    - name: '{{ redis_insight.config.default_user_dir }}'

Remove desktop shortcut for REDIS Insight:
  file.absent:
    - name: '{{ redis_insight.config.desktop_file }}'

Remove existing user profiles REDIS Insight config:
  cmd.run:
    - name: >-
        powershell.exe -ExecutionPolicy Bypass -NoProfile -Command
        "Get-ChildItem -Path 'C:\Users' -Directory -Exclude 'Public' |
        ForEach-Object { $dest = Join-Path $_.FullName '.redis-insight';
        if (Test-Path $dest) { Remove-Item -Path $dest -Recurse -Force } }"
    - onlyif: >-
        powershell.exe -ExecutionPolicy Bypass -NoProfile -Command
        "if (Test-Path 'C:\Users\*\.redis-insight') { exit 0 } else { exit 1 }"

Remove REDIS Insight from system PATH:
  win_path.absent:
    - name: '{{ redis_insight.config.app_dir }}'

Remove REDIS Insight wrapper script:
  file.absent:
    - name: '{{ redis_insight.config.app_dir }}\Launch-RedisInsight.ps1'
