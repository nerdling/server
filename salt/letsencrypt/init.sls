{# set a pillar with "email:address" #}
{% set email = salt["pillar.get"]("email") %}
{% set domains = salt["pillar.get"]("domains") %}
---
certbot ppa:
  pkgrepo.managed:
    - humanname: certbot
    - name: deb http://ppa.launchpad.net/certbot/certbot/ubuntu {{ salt["grains.get"]("oscodename") }} main 
    - keyserver: keyserver.ubuntu.com
    - keyid: 7BF576066ADA65728FC7E70A8C47BE8E75BCA694
    - comments: [' salt managed']

install certbot:
  pkg.installed:
    - name: python-certbot-apache
    - require:
      - pkgrepo: certbot ppa

setup certbot:
  cmd.run:
    - name: certbot -n --apache -m {{ email }}{% for domain in domains%} -d {{ domain }}{% endfor %}
    - onchanges:
      - pkg: install certbot
