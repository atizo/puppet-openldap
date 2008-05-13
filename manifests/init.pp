#######################################
# openldap module
# Puzzle ITC - haerry+puppet(at)puzzle.ch
# GPLv3
#######################################


# modules_dir { "openldap": }
class openldap {
    include open::base
}

class openldap::base {
    package{openldap
        ensure => present,
    }
}
