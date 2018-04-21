# == Class: awstats
#
class awstats(
  String           $package_name,
  Stdlib::Unixpath $config_dir_path,
  String           $default_template,
  Boolean          $config_dir_purge,
  Optional[Array]  $enable_plugins,
  String           $owner,
  String           $group,
) {

  unless ("${facts['os']['family']}${facts['os']['release']['major']}" =~ /((RedHat(6|7))|Debian|FreeBSD)/) {
    fail("Module ${module_name} is not supported on ${::facts['os']['family']} ${::facts['os']['release']['major']}.")
  }

  package{ $::awstats::package_name: }
  -> file { $::awstats::config_dir_path:
    ensure  => 'directory',
    owner   => $owner,
    group   => $group,
    mode    => '0755',
    recurse => true,
    purge   => $config_dir_purge,
  }

  if size($enable_plugins) > 0 {
    $load = prefix(downcase($enable_plugins), '::awstats::plugin::')
    include $load

    anchor { 'awstats::begin': }
    -> Class[$load]
    -> anchor { 'awstats::end': }
  }
}
