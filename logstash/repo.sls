{%- from 'logstash/map.jinja' import logstash with context %}

{%- if grains['os_family'] == 'Debian' %}
logstash_repo_https_apt_support:
  pkg.installed:
    - name: apt-transport-https

logstash-repo:
  pkgrepo.managed:
    - humanname: "Elastic repository for {{ logstash.repoversion }} packages"
    - name: deb https://artifacts.elastic.co/packages/{{ logstash.repoversion }}/apt stable main
    - file: /etc/apt/sources.list.d/elastic.list
    - gpgcheck: 1
    - key_url: https://artifacts.elastic.co/GPG-KEY-elasticsearch
    - require:
      - pkg: apt-transport-https

{%- elif grains['os_family'] == 'RedHat' %}
logstash-repo-key:
  cmd.run:
    - name:  rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

logstash-repo:
  pkgrepo.managed:
    - name: elastic
    - humanname: "Elastic repository for {{ logstash.repoversion }} packages"
    - baseurl: https://artifacts.elastic.co/packages/{{ logstash.repoversion }}/yum
    - gpgkey: https://artifacts.elastic.co/GPG-KEY-elasticsearch
    - gpgcheck: 1
    - disabled: False
    - require:
      - cmd: logstash-repo-key
{%- endif %}
