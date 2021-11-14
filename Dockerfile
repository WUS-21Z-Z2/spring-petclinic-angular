ARG DOCKER_HUB="docker.io"
ARG NGINX_VERSION="1.17.6"

FROM $DOCKER_HUB/library/node:12.20-alpine as build


COPY . /workspace/

ARG NPM_REGISTRY=" https://registry.npmjs.org"

RUN echo "registry = \"$NPM_REGISTRY\"" > /workspace/.npmrc                              && \
    cd /workspace/                                                                       && \
    npm install -g @angular/cli@latest                                                   && \
    npm install                                                                          && \
    ng build --prod --base-href=/petclinic/ --deploy-url=/petclinic/

FROM $DOCKER_HUB/library/nginx:$NGINX_VERSION AS runtime

ARG HTML_PATH="/usr/share/nginx/html/petclinic/"

COPY  --from=build /workspace/dist/ $HTML_PATH

RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx                        && \
    sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf && \
    sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf                           && \
    envsubst < $HTML_PATH/assets/config/rest-api-url.js.template                   \
             > $HTML_PATH/assets/config/rest-api-url.js


EXPOSE 8080

USER nginx

HEALTHCHECK     CMD     [ "service", "nginx", "status" ]


