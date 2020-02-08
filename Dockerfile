FROM drupal:8.7.8-apache

#Updates and Upgrades
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --assume-yes git && \
    apt-get install -y vim && \
    apt-get install -y zip && \
    apt-get install -y unzip && \
    apt-get install -y curl && \
    apt-get install -y wget

#GRAB DRUSH
RUN wget https://github.com/drush-ops/drush/archive/10.0.2.zip

#INSTALL NODE AND NPM
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
apt-get install -yq nodejs build-essential

# fix npm - not the latest version installed by apt-get
RUN npm install -g npm

# optional, check locations and packages are correct
RUN which node; node -v; which npm; npm -v;

EXPOSE 80

RUN chmod -R 0755 /usr/local/bin/
RUN curl https://beyondgrep.com/ack-2.22-single-file > /usr/local/bin/ack && chmod 0755 /usr/local/bin/ack

# Install Composer
RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin/ --filename=composer

WORKDIR /tmp
RUN curl -OL https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar && \
    cp /tmp/phpcs.phar /usr/local/bin/phpcs && \
    chmod +x /usr/local/bin/phpcs
# Set some useful defaults to phpcs
# show_progress - I like to see a progress while phpcs does its magic
# colors - Enable colors; My terminal supports more than black and white
# report_width - I am using a large display so I can afford a larger width
# encoding - Unicode all the way
RUN /usr/local/bin/phpcs --config-set show_progress 1 && \
    /usr/local/bin/phpcs --config-set colors 1 && \
    /usr/local/bin/phpcs --config-set report_width 140 && \
    /usr/local/bin/phpcs --config-set encoding utf-8
#ENTRYPOINT ["/usr/local/bin/phpcs"]

RUN composer global require drupal/coder:^8.3.1
RUN composer global require dealerdirect/phpcodesniffer-composer-installer
RUN /usr/local/bin/phpcs --config-set installed_paths /root/.composer/vendor/drupal/coder/coder_sniffer

#install PHPCBF PHP CODING BEAUTIFIER
RUN curl -sSL https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar -o phpcbf.phar
RUN chmod a+x phpcbf.phar
RUN mv phpcbf.phar /usr/local/bin/phpcbf

#install PHP Copy/Paste Detector
RUN curl -sSL https://phar.phpunit.de/phpcpd.phar -o phpcpd.phar
RUN chmod a+x phpcpd.phar
RUN mv phpcpd.phar /usr/local/bin/phpcpd
