# @summary Applies desired configuration via grubby
#
# This is a private class, that performs the necessary changes via grubby
#
class grubby::config {
  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $grubby::grub_default_kernel {

    $_default_kernel = "/boot/vmlinuz-${grubby::grub_default_kernel}"

    exec { 'set default kernel':
      command => "/sbin/grubby --set-default=${_default_kernel}",
      path    => ['/bin','/usr/bin'],
      unless  => "/sbin/grubby --default-kernel | grep -q ${_default_kernel}",
    }
  }
}
