package provide touch 1.0

package require evdev
package require params

namespace eval touch {

    array set data {
	t 0
	0.x 0 0.y 0
	1.x 0 1.y 0
	2.x 0 2.y 0
	3.x 0 3.y 0
	4.x 0 4.y 0
	5.x 0 5.y 0
	6.x 0 6.y 0
	7.x 0 7.y 0
	8.x 0 8.y 0
	9.x 0 9.y 0
    }

    proc evdev-handler {w event} {
	# puts "evdev-handler $w {$event}"
	if {[llength $event] == 0} { # skip the empty event
	    return
	}
	# if the event starts with a {t}, 
	# implement the change here
	if {[lindex $event 0] eq {t}} {
	    set t [lindex $event 1]
	    set event [lrange $event 2 end]
	} else {
	    set t $::touch::data(t)
	}
	# cache the coordinates
	set x $::touch::data($t.x)
	set y $::touch::data($t.y)
	set e <<TouchUpdate>>
	foreach {key value} $event {
	    switch $key {
		* { error "found an * inside the event" }
		t { 
		    event generate $w $e -data $t -x $x -y $y
		    set ::touch::data($t.x) $x
		    set ::touch::data($t.y) $y
		    set t $value
		    set x $::touch::data($t.x)
		    set y $::touch::data($t.y)
		    set e <<TouchUpdate>>
		}
		x { set x $value }
		y { set y $value }
		i { if {$value >= 0} { set e <<TouchBegin>> } else { set e <<TouchEnd>> } }
		default { error "unkonwn key value $key $value" }
	    }
	}
	event generate $w $e -data $t -x $x -y $y
	set ::touch::data($t.x) $x
	set ::touch::data($t.y) $y
	set ::touch::data(t) $t
    }
    
}

proc touch::init {w} {
    if {$::params::params(dev) ne {}} {
	::evdev::touch $::params::params(dev) [list ::touch::evdev-handler $w]
    }
}
