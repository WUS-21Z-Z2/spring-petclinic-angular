FROM node:12.20.2-alpine3.12 as build

WORKDIR /workspace
COPY . /workspace/

RUN npm install --no-audit \
    && npm install -g --no-audit @angular/cli@11.2.11
RUN ng build --prod --base-href=/petclinic/ --deploy-url=/petclinic/

FROM nginx:1.21.4 AS runtime

ARG HTML_PATH="/usr/share/nginx/html/petclinic/"

COPY --from=build /workspace/dist/ "$HTML_PATH"
COPY --chmod=0777 40-envsubst-rest-api-url.sh /docker-entrypoint.d/

RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx \
    && sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf \
    && sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf

EXPOSE 8080

HEALTHCHECK CMD ["service", "nginx", "status"]
CMD ["nginx", "-g", "daemon off;"]
