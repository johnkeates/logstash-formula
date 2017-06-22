{% from 'logstash/map.jinja' import logstash with context %}

{{ logstash.sysconfig_file }}:
  file.managed:
    - source: salt://logstash/files/sysconfig.jinja
    - user: root
    - group: root
    - mode: 0644
    - template: jinja
    - context:
        sysconfig: {{ logstash.sysconfig }}
