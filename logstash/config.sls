{%- from 'logstash/map.jinja' import logstash with context %}

logstash-config:
  file.serialize:
    - name: /etc/logstash/logstash.yml
    - dataset: {{ logstash.config }}
    - formatter: yaml
    - user: root
    - group: root
    - mode: 0644

{%- if logstash.inputs is defined %}
logstash-config-inputs:
  file.managed:
    - name: {{logstash.configdir}}conf.d/01-inputs.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/01-inputs.conf
    - template: jinja
    - require:
      - pkg: logstash-pkg
{%- else %}
logstash-config-inputs:
  file.absent:
    - name: {{logstash.configdir}}conf.d/01-inputs.conf
{%- endif %}

{%- if logstash.filters is defined %}
logstash-config-filters:
  file.managed:
    - name: {{logstash.configdir}}conf.d/02-filters.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/02-filters.conf
    - template: jinja
    - require:
      - pkg: logstash-pkg
{%- else %}
logstash-config-filters:
  file.absent:
    - name: {{logstash.configdir}}conf.d/02-filters.conf
{%- endif %}

{%- if logstash.outputs is defined %}
logstash-config-outputs:
  file.managed:
    - name: {{logstash.configdir}}conf.d/03-outputs.conf
    - user: root
    - group: root
    - mode: 755
    - source: salt://logstash/files/03-outputs.conf
    - template: jinja
    - require:
      - pkg: logstash-pkg
{%- else %}
logstash-config-outputs:
  file.absent:
    - name: {{logstash.configdir}}conf.d/03-outputs.conf
{%- endif %}
