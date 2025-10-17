# Gunakan image PHP 8.2 dengan Apache bawaan
FROM php:8.2-apache

# Install ekstensi PHP yang dibutuhkan Laravel
RUN apt-get update && apt-get install -y \
    git zip unzip libpq-dev libonig-dev libxml2-dev libzip-dev && \
    docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath opcache

# Aktifkan mod_rewrite Apache
RUN a2enmod rewrite

# Salin seluruh file proyek ke dalam container
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer

# Install dependency Laravel
RUN composer install --no-dev --optimize-autoloader

# Set permission folder penting
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Copy konfigurasi Apache (agar public/ jadi root)
RUN echo '<VirtualHost *:80>\n\
    DocumentRoot /var/www/html/public\n\
    <Directory /var/www/html/public>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/000-default.conf

# Expose port 80
EXPOSE 80

RUN php artisan config:cache && php artisan route:cache && php artisan migrate --force

# Jalankan Apache
CMD ["apache2-foreground"]
