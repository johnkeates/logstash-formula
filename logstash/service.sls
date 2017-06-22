{%- from 'logstash/map.jinja' import logstash with context %}

include:
    - logstash.install

logstash-svc:
  service.running:
    - name: {{logstash.svc}}
    - enable: true
    - require:
        - sls: logstash.install
    - watch:
      - file: /etc/logstash/jvm.options
      - file: {{ logstash.sysconfig_file }}
      - file: logstash-config
      - file: logstash-config-inputs
      - file: logstash-config-filters
      - file: logstash-config-outputs
{%- if logstash.patterns is defined %}
  {%- for name, patterns in logstash.patterns.items() %}
      - file: /etc/logstash/patterns/{{ name }}
  {% endfor %}
{% endif %}
