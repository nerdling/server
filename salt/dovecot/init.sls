---
install dovecot:
  pkg.installed:
    - pkgs:
      - dovecot-imapd
      - dovecot-sieve

ensure dovecot is running:
  service.running:
    - name: dovecot
    - enable: true

{% for dcf in ("10-master", "10-mail", "10-ssl", "15-lda") %}
/etc/dovecot/conf.d/{{ dcf }}.conf:
  file.managed:
    - source: salt://dovecot/files/{{ dcf }}.conf
{% endfor %}
