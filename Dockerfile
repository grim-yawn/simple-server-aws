FROM nginx:1.21.6
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
CMD nginx -g daemon off;