SUBSTITUTED_FILE="/usr/share/nginx/html/petclinic/assets/config/rest-api-url.js"
envsubst '$REST_API_HOSTNAME,$REST_API_PORT' \
    <"$SUBSTITUTED_FILE.template" \
    >"$SUBSTITUTED_FILE"
cat "$SUBSTITUTED_FILE"
