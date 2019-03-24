{% set dismods = () %}
{# set domains in a pillar "domains: a,b,c" #}
{% set ensites = salt["pillar.get"]("domains") %}
{% set enmods = ("socache_shmcb", "ssl") %}
---
include:
  - letsencrypt

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
      - file: create-site-{{ site }}
      {% endfor %}
      {% for mod in enmods %}
      - file: enable-mod-conf-{{ mod }}
      - file: enable-mod-load-{{ mod }}
      {% endfor %}
      {% for mod in dismods %}
      - file: disable-mod-conf-{{ mod }}
      - file: disable-mod-load-{{ mod }}
      {% endfor %}

{% for site in ensites %}
create-site-{{ site }}:
  file.managed:
    - name: /etc/apache2/sites-available/{{ site }}.conf
    - source: salt://apache2/files/default-ssl.conf.j2
    - template: jinja
    - context:
      domain: {{ site }}
    - require:
      - pkg: install apache2
      - cmd: setup certbot

enable-site-{{ site }}:
  file.symlink:
    - name: /etc/apache2/sites-enabled/{{ site }}.conf
    - target: /etc/apache2/sites-available/{{ site }}.conf
    - require:
      - pkg: install apache2
      - file: create-site-{{ site }}
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
