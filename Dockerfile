# Gunakan PHP dengan Apache
FROM php:8.2-apache

# Install dependensi sistem
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev zip git unzip && \
    docker-php-ext-install pdo pdo_mysql gd

# Aktifkan mod_rewrite untuk Laravel routing
RUN a2enmod rewrite

# Copy source ke direktori Apache
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Set permission storage dan bootstrap/cache
RUN chmod -R 775 storage bootstrap/cache

# Jalankan build frontend kalau pakai Vite
RUN npm install && npm run build

# Konfigurasi Apache agar Laravel di-root ke folder public
RUN sed -i 's|DocumentRoot /var/www/html|DocumentRoot /var/www/html/public|' /etc/apache2/sites-available/000-default.conf

# Pastikan AllowOverride diaktifkan untuk .htaccess Laravel
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

EXPOSE 80

# Jalankan Apache
CMD ["apache2-foreground"]
