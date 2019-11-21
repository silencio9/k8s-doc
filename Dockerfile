FROM hank997/gitbook:v1.0.0
RUN mkdir -p /var/www/book
COPY . /var/www/book
COPY gitbook.conf /etc/nginx/conf.d
RUN cd /var/www/book \
    && gitbook install \
    && gitbook build
