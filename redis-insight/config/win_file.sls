# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set browser_policies = redis_insight.config.get('browser_policies', {}) %}

Ensure Default User config-directory exists:
  file.directory:
    - makedirs: True
    - name: '{{ redis_insight.config.default_user_dir }}'

Ensure REDIS Insight is in system PATH:
  win_path.exists:
    - name: '{{ redis_insight.config.app_dir }}'
    - require:
      - sls: {{ tplroot }}.package.install

Manage REDIS Insight wrapper script:
  file.managed:
    - context:
        redis_insight: {{ redis_insight | json }}
    - name: '{{ redis_insight.config.app_dir }}\Launch-RedisInsight.ps1'
    - require:
      - sls: {{ tplroot }}.package.install
    - source: salt://{{ tplroot }}/files/default/Launch-RedisInsight.ps1.jinja
    - template: jinja

Manage desktop shortcut for REDIS Insight:
  file.shortcut:
    - arguments: >-
        -WindowStyle Hidden -ExecutionPolicy Bypass -File
        "{{ redis_insight.config.app_dir }}\Launch-RedisInsight.ps1"
    - icon_location: '{{ redis_insight.config.app_dir }}\Redis Insight.exe'
    - name: '{{ redis_insight.config.desktop_file }}'
    - require:
      - file: 'Manage REDIS Insight wrapper script'
    - target: 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
    - working_dir: '{{ redis_insight.config.app_dir }}'

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

{%- for policy, val in browser_policies.items() %}
Set Browser Policy - {{ policy }}:
  reg.present:
    - name: 'HKLM\SOFTWARE\Policies\Google\Chrome'
    - require:
      - sls: {{ tplroot }}.package.install
    {%- if val is boolean %}
    - vdata: {{ 1 if val else 0 }}
    - vname: '{{ policy }}'
    - vtype: REG_DWORD
    {%- elif val is number %}
    - vdata: {{ val }}
    - vname: '{{ policy }}'
    - vtype: REG_DWORD
    {%- else %}
    - vdata: '{{ val }}'
    - vname: '{{ policy }}'
    - vtype: REG_SZ
    {%- endif %}
{%- endfor %}
