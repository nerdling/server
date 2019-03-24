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
    - name: certbot --apache -d mx.lavergne.me
    - onchanges:
      - pkg: install certbot
