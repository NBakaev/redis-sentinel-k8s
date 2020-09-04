FROM redis:6.0.7-alpine
RUN apk add --no-cache bash curl jq
COPY *.sh /
RUN chmod +x /*.sh
ENTRYPOINT ["/run.sh"]