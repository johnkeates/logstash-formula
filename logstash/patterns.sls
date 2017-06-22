{% from 'logstash/map.jinja' import logstash with context %}

{% if logstash.patterns is defined %}
  {% for name, patterns in logstash.patterns.items() %}
/etc/logstash/patterns/{{ name }}:
  file.managed:
    - makedirs: True
    - mode: 0644
    - user: root
    - group: root
    {% if pattern %}
    - contents:
      {% for pattern in patterns %}
        - {{ pattern }}
      {% endfor %}
    {% endif %}
  {% endfor %}
{% endif %}
