# @summary Applies kernel parameter configuration via grubby
#
# @example Add Single Parameter
#   grubby::kernel_opt{'keyword':}
#
# @example Delete a Single Parameter
#   grubby::kernel_opt{'selinix':
#     ensure => 'absent',
#   }
#
# @example Add Parameter with Value
#   grubby::kernel_opt{'memsize':
#     value  => '22',
# }
#
# @example Add a Parameter with Multiple Values 
#  grubby::kernel_opt{'disks':
#    value => ['vda', 'vdb'],
#  }
#
# @param opt Kernel option
# @param ensure add or delete kernel option
# @param value Value or values of kernel options
# @param scope Which kernels to apply parameters to
#
define grubby::kernel_opt (
  Pattern[/\S+/] $opt                                                                              = $name,
  Enum['present', 'absent']                             $ensure                                    = 'present',
  Variant[Enum['DEFAULT','ALL'],Pattern[/^TITLE=.+$/]]  $scope                                     = 'DEFAULT',
  Optional[Variant[Pattern[/^\S+$/], Integer, Array[Variant[Pattern[/^\S+$/], Integer],1]]] $value =  undef,
){

  $_opt = $value ? {
    Undef   => $opt,
    Array   => "${opt}=\"${join($value,' ')}\"",
    default => "${opt}=${value}",
  }

  case $ensure {
    'present': {
      exec { "Ensure ${_opt} kernel option is set for ${scope}":
        command => "/sbin/grubby --update-kernel=${scope} --args=${_opt}",
        path    => ['/bin','/usr/bin'],
        unless  => "/sbin/grubby --info=${scope} | grep ^args= | test -z \"$(grep -wv ${_opt})\"",
      }
    }
    'absent': {
      exec { "Ensure ${opt} kernel option is absent for ${scope}":
        command => "/sbin/grubby --update-kernel=${scope} --remove-args=${opt}",
        path    => ['/bin','/usr/bin'],
        unless  => "/sbin/grubby --info=${scope} | grep ^args= | test -z \"$(grep -w ${opt})\"",
      }
    }
    default: {
      fail('Incorect value of field ensure for ensure parameter!')
    }
  }
}
