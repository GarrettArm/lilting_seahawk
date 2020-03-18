FROM drupal:8.7.3-fpm

RUN ls

RUN rm -R /var/www/html

RUN apt update \
    && apt install wget git curl nano tree unzip mysql-client -y

RUN cd /tmp \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && mv composer.phar /usr/bin/composer \
    && php -r "unlink('composer-setup.php');"

RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
    && chmod +x drush.phar \
    && mv drush.phar /usr/bin/drush

RUN composer create-project drupal-composer/drupal-project:8.x-dev /drupal_app --stability dev --no-interaction --no-install
COPY ./config/drupal/drupal_composer.json /drupal_app/composer.json
WORKDIR /drupal_app
RUN php -d memory_limit=-1 /usr/bin/composer update \
    && chown -R www-data:www-data /drupal_app
COPY ./config/drupal/settings.php /tmp/drupal_local_settings.php
RUN cat /tmp/drupal_local_settings.php >> /drupal_app/web/sites/default/settings.php
RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
