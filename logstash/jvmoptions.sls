{% from "logstash/map.jinja" import logstash with context %}

/etc/logstash/jvm.options:
  file.managed:
    - mode: 0644
    - user: root
    - group: root
    - contents: {{ logstash.jvm_opts }}
