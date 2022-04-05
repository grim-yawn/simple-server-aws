FROM nginx:1.21.6
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 8080
CMD nginx -g daemon off;