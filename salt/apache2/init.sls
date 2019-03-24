---
install apache2:
  pkg.installed:
    - name: apache2

apache2 running:
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: install apache2

available-sites:
  file.recurse:
    - name: /etc/apache2/sites-available
    - source: salt://apache2/files/sites-available
    - require:
      - pkg: install apache2

{% for site in ("000-default", "000-default-le-ssl", "001-cafe-rustica") %}
enable-site-{{ site }}:
  file.symlink:
    - name: /etc/apache2/sites-enabled/{{ site }}.conf
    - target: /etc/apache2/sites-available/{{ site }}.conf
    - require:
      - pkg: install apache2
    - watch:
      - service: apache2 running
{% endfor %}
