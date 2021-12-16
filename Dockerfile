FROM nginx:1.21.0


# Install necessary packages 
RUN apt-get update -y && apt-get install -y apt-transport-https ca-certificates wget \
    gnupg2 lsb-release openssl && rm -rf /var/lib/apt/lists/*


RUN wget https://packages.sury.org/php/apt.gpg && apt-key add apt.gpg \
	&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php7.list
	

RUN apt-get update -y && apt-get install -y php7.1-xml php7.1-mbstring php7.1-zip php7.1-mysql \
    php7.1-opcache php7.1-json php7.1-curl php7.1-ldap php7.1-cgi php7.1-imap \
    php7.1-cli php7.1-fpm php7.1-common php7.1-bcmath libapache2-mod-php7.1 \
    cron && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/user  nginx/user  www-data/g' /etc/nginx/nginx.conf

# Force PHP to log to nginx
RUN echo "catch_workers_output = yes" >> /etc/php/7.1/fpm/php-fpm.conf

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log

# Enable php by default
ADD default.conf /etc/nginx/conf.d/default.conf

WORKDIR /usr/share/nginx/

RUN rm -rf *

# Copying local files into the container
ADD . .

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php composer-setup.php --version=1.7.2 \
	&& php -r "unlink('composer-setup.php');"
RUN php composer.phar install
RUN chgrp -R www-data . storage bootstrap/cache
RUN chmod -R ug+rwx . storage bootstrap/cache

# Add to crontab file

RUN touch /etc/cron.d/faveo-cron \
    && echo '* * * * * php /usr/share/nginx/artisan schedule:run > /dev/null 2>&1' >>/etc/cron.d/faveo-cron \
    && chmod 0644 /etc/cron.d/faveo-cron \
    && crontab /etc/cron.d/faveo-cron \
    && sed -i "s/max_execution_time = .*/max_execution_time = 120/" /etc/php/7.1/fpm/php.ini \
    && php -m

CMD cron && service php7.1-fpm start && nginx -g "daemon off;"