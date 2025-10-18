FROM quay.io/keycloak/keycloak:22.0.0 as builder

WORKDIR /opt/keycloak
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:22.0.0
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY themes/ /opt/keycloak/themes/

WORKDIR /opt/keycloak
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]