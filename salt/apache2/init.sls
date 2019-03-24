{% set dismods = ("mpm_event",) %}
{% set ensites = ("000-default", "000-default-le-ssl", "001-cafe-rustica") %}
{% set enmods = ("mpm_prefork", "socache_shmcb", "ssl") %}
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
    - watch:
      {% for site in ensites %}
      - file: enable-site-{{ site }}
      {% endfor %}
      {% for mod in enmods %}
      - file: enable-mod-conf-{{ mod }}
      - file: enable-mod-load-{{ mod }}
      {% endfor %}
      {% for mod in dismods %}
      - file: disable-mod-conf-{{ mod }}
      - file: disable-mod-load-{{ mod }}
      {% endfor %}

available-sites:
  file.recurse:
    - name: /etc/apache2/sites-available
    - source: salt://apache2/files/sites-available
    - require:
      - pkg: install apache2

{% for site in ensites %}
enable-site-{{ site }}:
  file.symlink:
    - name: /etc/apache2/sites-enabled/{{ site }}.conf
    - target: /etc/apache2/sites-available/{{ site }}.conf
    - require:
      - pkg: install apache2
{% endfor %}

{% for mod in enmods %}
enable-mod-conf-{{ mod }}:
  file.symlink:
    - name: /etc/apache2/mods-enabled/{{ mod }}.conf
    - target: /etc/apache2/mods-available/{{ mod }}.conf
    - require:
      - pkg: install apache2

enable-mod-load-{{ mod }}:
  file.symlink:
    - name: /etc/apache2/mods-enabled/{{ mod }}.load
    - target: /etc/apache2/mods-available/{{ mod }}.load
    - require:
      - pkg: install apache2
{% endfor %}

{% for mod in dismods %}
disable-mod-conf-{{ mod }}:
  file.absent:
    - name: /etc/apache2/mods-enabled/{{ mod }}.conf
    - require:
      - pkg: install apache2
disable-mod-load-{{ mod }}:
  file.absent:
    - name: /etc/apache2/mods-enabled/{{ mod }}.load
    - require:
      - pkg: install apache2
{% endfor %}
