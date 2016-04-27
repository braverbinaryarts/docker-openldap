FROM ubuntu:14.04
MAINTAINER Ryan Barber <ryan@directly.com>

ENV LDAP_BASE 'dc=example,dc=com'
ENV LDAP_PASS 'password'
ENV LDAP_ORGN 'Example, Inc.'
ENV LDAP_FQDN 'example.com'

ENV DEBIAN_FRONTEND 'noninteractive'

RUN apt-get update && apt-get -y -q upgrade

RUN apt-get -y -q install rsyslog

RUN echo "slapd slapd/root_password password ${LDAP_PASS}" | debconf-set-selections &&\
  echo "slapd slapd/root_password_again password ${LDAP_PASS}" | debconf-set-selections &&\
  echo "slapd slapd/internal/adminpw password ${LDAP_PASS}" | debconf-set-selections &&\
  echo "slapd slapd/internal/generated_adminpw password ${LDAP_PASS}" | debconf-set-selections &&\
  echo "slapd slapd/password1 password ${LDAP_PASS}" | debconf-set-selections &&\
  echo "slapd slapd/password2 password ${LDAP_PASS}" | debconf-set-selections &&\
  echo "slapd slapd/domain string ${LDAP_FQDN}" | debconf-set-selections &&\
  echo "slapd shared/organization string '${LDAP_ORGN}'" | debconf-set-selections &&\
  echo "slapd slapd/backend string HDB" | debconf-set-selections &&\
  echo "slapd slapd/purge_database boolean true" | debconf-set-selections &&\
  echo "slapd slapd/move_old_database boolean true" | debconf-set-selections &&\
  echo "slapd slapd/allow_ldap_v2 boolean false" | debconf-set-selections &&\
  echo "slapd slapd/no_configuration boolean false" | debconf-set-selections

RUN apt-get install -y -q slapd ldap-utils gnutls-bin

RUN apt-get clean

RUN dpkg-reconfigure slapd

# We could stop here.

ADD files/openssh.ldif /etc/ldap/slapd.d/cn\=config/cn\=schema/cn\=\{4\}openssh.ldif
RUN chown openldap:openldap /etc/ldap/slapd.d/cn\=config/cn\=schema/cn\=\{4\}openssh.ldif
