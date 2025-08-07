<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the website, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */

@ini_set('upload_max_filesize', '128M');
@ini_set('post_max_size', '128M');
@ini_set('memory_limit', '256M');
@ini_set('max_execution_time', '300');
@ini_set('max_input_time', '300');

define('DB_NAME', getenv('WORDPRESS_DB_NAME'));
define('DB_USER', getenv('WORDPRESS_DB_USER'));
define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD'));
define('DB_HOST', getenv('WORDPRESS_DB_HOST'));

/** Database charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The database collate type. Don't change this if in doubt. */
define('DB_COLLATE', '');

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY', 'K7CcG|QE$W[^_W?4v`vm^UCE*NQQ:IY2B]AyztM7D,&*9pW/Gr/KyP]oiW/,{ts/');
define('SECURE_AUTH_KEY', 'e7)7$F=avNmq}OoTh*GCv-v0Q[ZeYZ/>~2q;7r{)[rz3Ukcw.zn$FunEDR$CE!KP');
define('LOGGED_IN_KEY', '_nG]6F,?(BDMP*m2Iy0sgNnwaLeR//F!7$@&AO|VNG;i`kA m~r5sN.Frxi4FD!D');
define('NONCE_KEY', '_#C:/&i+0p)!tg7)m4*?7);[xkIUxM{S0w+t$8k>`auRU;PA;HwX?$8)G33?mbe[');
define('AUTH_SALT', '%A2bWnt$P? Y:!9Y;_Ae*fuS5x^uh7+}=OZX /5r,FXA2FW>S#z;ZlHSkz~xl:k)');
define('SECURE_AUTH_SALT', 'avvx!f5k:in6,J>,5n=9}tbn4CLjIu4GJOP#0=?^iuVM@Au5&sps 5i;(xaU@P&a');
define('LOGGED_IN_SALT', 't.A$G&?Gm^S]l(>ek]Wc{|=q^H/aH<PQqd>Mr%5I6qB4Xd;8t3cm]x~>]CSBKe@v');
define('NONCE_SALT', '[2:XY#toI,q7D;!lzy4{H~^Fd&l`+0O!{]SM%.[nA,w0]ZoC|UBYweu<z[d?e@L:');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 *
 * At the installation time, database tables are created with the specified prefix.
 * Changing this value after WordPress is installed will make your site think
 * it has not been installed.
 *
 * @link https://developer.wordpress.org/advanced-administration/wordpress/wp-config/#table-prefix
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
 */
define('WP_DEBUG', false);

/* Add any custom values between this line and the "stop editing" line. */



/** Absolute path to the WordPress directory. */
if (!defined('ABSPATH')) {
	define('ABSPATH', __DIR__ . '/');
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
