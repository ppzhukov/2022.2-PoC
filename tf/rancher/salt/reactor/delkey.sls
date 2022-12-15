{% if data['act'] == 'denied' %}
remove_key:
  wheel.key.delete:
    - match: {{ data['id'] }}
{% endif %}
