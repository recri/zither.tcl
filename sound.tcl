package provide ::sound 1.0

package require faust::pm::ks

namespace eval ::sound {
    foreach x {0 1 2 3 4 5 6 7 8 9 f} {
	faust::pm::ks ::sound::$x
    }
}

proc ::sound::note {action id freq} {
    switch -exact $action {
	+ {
	    ::sound::$id configure -freq $freq -gate 1
	}
	. { 
	    if {[::sound::$id cget -freq] != $freq} { ::sound::$id configure -gate 0 }
	    ::sound::$id configure -freq $freq -gate 1 
	}
	- {
	    ::sound::$id configure -gate 0 
	}
    }
}
