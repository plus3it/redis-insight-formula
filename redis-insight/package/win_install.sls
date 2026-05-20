# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}

{%- set target_arch = grains.get('osarch', 'x86_64') %}
{%- set redis_pkg = 'C:\\Windows\\TEMP\\Redis-Insight-win-installer.exe' %}
{%- set target_version = redis_insight.config.get('target_version', '') %}

{#- Determine the download URI #}
{%- set download_uri = redis_insight.pkg.get('download_uri', '') %}
{%- set api_response = {} %}

{%- if not download_uri %}
  {%- set api_url =
      'https://api.github.com/repos/redis/RedisInsight/releases/latest' %}
  {%- set api_response = salt['http.query'](
        api_url, decode=True, decode_type='json'
      ) %}

  {%- if 'dict' in api_response and 'tag_name' in api_response['dict'] %}
    {%- set latest_tag = api_response['dict']['tag_name'] %}
    {%- set version_num = latest_tag | replace('v', '') %}
    {%- set download_uri =
      'https://github.com/redis/RedisInsight/releases/download/' ~ latest_tag ~
      '/Redis-Insight-win-installer.exe' %}
  {%- endif %}
    {%- if not target_version %}
      {%- set target_version = latest_tag | replace('v', '') %}
    {%- endif %}
{%- endif %}

{%- if not download_uri %}
Halt Installation Due to Missing URL:
  test.fail_without_changes:
    - name: >
        Failed to construct download_uri. Please provide the URL manually in
        Pillar.
    - failhard: True
{%- elif redis_insight.pkg.download_uri %}
Download REDIS Insight Installer-EXE:
  file.managed:
    - name: '{{ redis_pkg }}'
    - onchanges_in:
      - cmd: 'Install REDIS Insight from Installer-EXE'
    - skip_verify: True
    - source: '{{ redis_insight.pkg.download_uri }}'

{%- else %}
Download REDIS Insight Installer-EXE:
  cmd.run:
    - name: 'curl -sSLf -o {{ redis_pkg }} {{ download_uri }}'
    - onchanges_in:
      - cmd: 'Install REDIS Insight from Installer-EXE'
    - unless: 'test -s {{ redis_pkg }}'
{%- endif %}

Install REDIS Insight from Installer-EXE:
  cmd.run:
    - name: >-
        Start-Process -FilePath '{{ redis_pkg }}'
        -ArgumentList '/S', '/AllUsers'
        -Wait
    - require:
      {%- if redis_insight.pkg.download_uri %}
      - file: 'Download REDIS Insight Installer-EXE'
      {%- else %}
      - cmd: 'Download REDIS Insight Installer-EXE'
      {%- endif %}
    - shell: powershell
    - unless: >-
        powershell.exe -ExecutionPolicy Bypass -NoProfile -Command
        "$ErrorActionPreference = 'Stop';
        $v = '{{ target_version }}';
        $b = 'C:\Program Files\Redis Insight\Redis Insight.exe';
        if (!$v -or !(Test-Path $b)) { exit 1 };
        $i = [version](Get-Item $b).VersionInfo.ProductVersion;
        if ($i -eq [version]$v) { exit 0 } else { exit 1 }"
