FROM ubuntu:bionic
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q update
RUN apt-get -q -y purge firefox gnome-software-plugin-snap snapd
RUN apt-get -y --purge -o APT::Autoremove::RecommendsImportant=0 -o APT::Autoremove::SuggestsImportant=0 autoremove
RUN apt-get -q -y -o DPkg::Options::=--force-confold -o DPkg::Options::=--force-confdef upgrade
ADD https://github.com/saltstack/salt-bootstrap/raw/stable/bootstrap-salt.sh /bootstrap-salt.sh
RUN chmod +x /bootstrap-salt.sh
RUN /bootstrap-salt.sh -X -K stable
ADD pillar /srv/pillar
ADD salt /srv/salt
RUN salt-call --state-output=mixed --output-diff --local state.apply mock=True
