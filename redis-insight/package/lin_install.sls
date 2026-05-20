# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as redis_insight with context %}

{%- set target_arch = grains.get('osarch', 'x86_64') %}
{%- set redis_rpm = '/tmp/Redis-Insight-linux-' ~ target_arch ~ '.rpm' %}

{% set is_fips = False %}
{% if salt['file.file_exists']('/proc/sys/crypto/fips_enabled') %}
  {% set is_fips = (salt['file.read']('/proc/sys/crypto/fips_enabled') | trim == '1') %}
{% endif %}

{#- Determine the download URI #}
{%- set download_uri = redis_insight.pkg.download_uri %}
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
      '/Redis-Insight-linux-' ~ target_arch ~ '.rpm' %}
  {%- endif %}
{%- endif %}

{%- if not download_uri %}
Halt Installation Due to Missing URL:
  test.fail_without_changes:
    - name: 'Failed to construct download_uri. Please provide the URL manually in Pillar.'
    - failhard: True
{%- elif redis_insight.pkg.download_uri %}
Download REDIS Insight RPM:
  file.managed:
    - name: '{{ redis_rpm }}'
    - skip_verify: True
    - source: '{{ redis_insight.pkg.download_uri }}'
    - onchanges_in:
      - pkg: 'Install REDIS Insight Dependencies (Explicit)'

{%- else %}
Download REDIS Insight RPM:
  cmd.run:
    - name: 'curl -sSLf -o {{ redis_rpm }} {{ download_uri }}'
    - unless: 'test -s {{ redis_rpm }}'
    - onchanges_in:
      - pkg: 'Install REDIS Insight Dependencies (Explicit)'
{%- endif %}

{%- if is_fips %}
  {%- if salt['grains.get']('selinux:enabled', False) %}
Allow Redis Insight to bind to internal ports:
  selinux.boolean:
    - name: nis_enabled
    - value: True
    - persist: True
    - require:
      - pkg: 'Install SELinux management tools'
  {%- endif %}

Ensure REDIS Insight app-directory permissions:
  file.directory:
    - name: "{{ redis_insight.config.app_dir }}"
    - user: root
    - group: {{ redis_insight.config.get('system_group', 'root') }}
    - mode: 755
    - recurse:
        - mode
    - require:
        - cmd: 'Extract REDIS Insight Files'

Extract REDIS Insight Files:
  cmd.run:
    - cwd: /
    - name: 'rpm2cpio {{ redis_rpm }} | cpio -idmv'
    - require:
      - cmd: 'Install REDIS Insight Dependencies (Dynamic)'
    - umask: 0022
    - unless: 'rpm -q {{ redis_insight.pkg.name }}'

Install REDIS Insight Dependencies (Dynamic):
  cmd.run:
    - name: >
        rpm -qpR --nodigest --nosignature {{ redis_rpm }} |
        grep -v '^rpmlib(' |
        xargs -d '\n' dnf install -y
    - require:
      - pkg: 'Install REDIS Insight Dependencies (Explicit)'
    - unless: 'rpm -q {{ redis_insight.pkg.name }}'

Install REDIS Insight RPM (DB only):
  cmd.run:
    - name: 'rpm -ivh --justdb --nodigest --nosignature {{ redis_rpm }}'
    - require:
      - cmd: 'Extract REDIS Insight Files'
    - unless: 'rpm -q {{ redis_insight.pkg.name }}'

Restore REDIS Insight SELinux contexts:
  cmd.run:
    - name: 'fixfiles -R {{ redis_insight.pkg.name }} restore'
    - onchanges:
      - cmd: 'Install REDIS Insight RPM (DB only)'

Synchronize DNF Database:
  cmd.run:
    - name: 'dnf clean expire-cache'
    - onchanges:
      - cmd: 'Install REDIS Insight RPM (DB only)'
{%- else %}
Install REDIS Insight RPM:
  pkg.installed:
    - require:{%- if redis_insight.pkg.download_uri %}
      - file: 'Download REDIS Insight RPM'
      {%- else %}
      - cmd: 'Download REDIS Insight RPM'
      {%- endif %}
    - sources:
      - {{ redis_insight.pkg.name }}: {{ redis_rpm }}
{%- endif %}

Install REDIS Insight Dependencies (Explicit):
  pkg.installed:
    - pkgs:
      - alsa-lib
      - at-spi2-atk
      - dejavu-sans-fonts
      - libX11
      - libXcomposite
      - libXdamage
      - libXext
      - libXfixes
      - libXrandr
      - libdrm
      - mesa-libgbm
      - nss
    - require:
      {%- if redis_insight.pkg.download_uri %}
      - file: 'Download REDIS Insight RPM'
      {%- else %}
      - cmd: 'Download REDIS Insight RPM'
      {%- endif %}

Install SELinux management tools:
  pkg.installed:
    - name: policycoreutils-python-utils

Remove staged REDIS Insight RPM:
  file.absent:
    - name: '{{ redis_rpm }}'
    - require:
      {%- if is_fips %}
      - cmd: 'Install REDIS Insight RPM (DB only)'
      {%- else %}
      - pkg: 'Install REDIS Insight RPM'
      {%- endif %}
