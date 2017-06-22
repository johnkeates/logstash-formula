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
      - file: logstash-config
      - file: logstash-config-inputs
      - file: logstash-config-filters
      - file: logstash-config-outputs
