{% set certbot_email = salt["pillar.get"]("certbot_email") -%}
{% set domains = salt["pillar.get"]("domains") -%}
---
certbot ppa:
  pkgrepo.managed:
    - humanname: certbot
    - name: deb http://ppa.launchpad.net/certbot/certbot/ubuntu {{ salt["grains.get"]("oscodename") }} main 
    - keyserver: keyserver.ubuntu.com
    - keyid: 7BF576066ADA65728FC7E70A8C47BE8E75BCA694
    - comments: [' salt managed']

install certbot packages:
  pkg.installed:
    - pkgs:
      - python3-certbot-apache
      - python3-certbot-dns-cloudflare
    - require:
      - pkgrepo: certbot ppa

install cloudflare credentials:
  file.managed:
    - name: /etc/cloudflare.ini
    - mode: 600
    - source: salt://letsencrypt/files/cloudflare.ini.j2
    - template: jinja

setup certbot:
  cmd.run:
    - name: certbot -n -a dns-cloudflare --dns-cloudflare-credentials /etc/cloudflare.ini -i apache --agree-tos --email {{ certbot_email }} {% for domain in domains %} -d {{ domain }}{% endfor %}
    - creates:
      {% for domain in domains %}
      - /etc/letsencrypt/renewal/{{ domain }}.conf
      {% endfor %}
    - require:
      - file: install cloudflare credentials
      - pkg: install certbot packages
