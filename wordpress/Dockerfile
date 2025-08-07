FROM php:8.1-apache

# Install mysqli and enable it
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli

# Enable Apache rewrite module
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Set permissions (optional)
RUN chown -R www-data:www-data /var/www/html

# Copy the WordPress files into the container

# Copy WordPress files from host to container
COPY . /var/www/html/

# Optional: Permissions
RUN chown -R www-data:www-data /var/www/html