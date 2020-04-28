FROM drupal:8.8.5-fpm

# blow up the existing drupal install
# we only want to use all the dependencies the drupal image comes with
RUN rm -R /var/www/html

RUN apt update \
    && apt install wget git curl nano tree unzip mysql-client -y \
    && apt upgrade -y

# install composer
RUN cd /tmp \
    && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && mv composer.phar /usr/bin/composer \
    && php -r "unlink('composer-setup.php');"

# install drush
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
    && chmod +x drush.phar \
    && mv drush.phar /usr/bin/drush

# create the default drupal project (not yet installing it)
RUN composer create-project drupal/recommended-project /drupal_app --stability dev --no-interaction --no-install

# move our specific composer.json inside
COPY --chown=www-data:www-data ./config/drupal/drupal_composer.json /drupal_app/composer.json

WORKDIR /drupal_app

# install drupal & its dependencies, using composer
RUN php -d memory_limit=-1 /usr/bin/composer update

# Move the drupal production configs into place
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN cp /drupal_app/web/sites/default/default.settings.php /drupal_app/web/sites/default/settings.php
RUN cp /drupal_app/web/sites/default/default.services.yml /drupal_app/web/sites/default/services.yml
# Add our unique settings
# (this two-step process is a hack that appends text to an existing file within the container [copy in text, then cat to file])
COPY ./config/drupal/settings.php /tmp/drupal_local_settings.php
RUN cat /tmp/drupal_local_settings.php >> /drupal_app/web/sites/default/settings.php

RUN chown -R www-data:www-data /drupal_app