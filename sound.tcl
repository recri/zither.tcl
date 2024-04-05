package provide sound 1.0

# package require sdrtcl::jack-client
package require sdrtcl::gain
package require faust::pm::ks

# system:playback_1 {direction input physical 1 type audio connections {}} system:playback_2 {direction input physical 1 type audio connections {}}

namespace eval sound {
}

# get a jack client to manipulate the server
# sdrtcl::jack-client sound::jack

# make one gain unit to combine all the string outputs together
sdrtcl::gain g

# connect the gain to the system playback device
# sound::jack connect sound::gain:out_i system:playback_1
# sound::jack connect sound::gain:out_i system:playback_2
    
foreach x {0 1 2 3 4 5 6 7 8 9 f} {
    # create a string model
    faust::pm::ks sound::v$x
    # connect its output to the gain
    # sound::jack connect sound::$x:out_0 sound::gain:in_i
}
    
# puts [::sound::jack list-ports]

proc ::sound::note {action id freq} {
    switch -exact $action {
	+ {
	    sound::v$id configure -freq $freq -gate 1 -gain 0.25
	}
	. { 
	    if {[sound::v$id cget -freq] != $freq} { 
		sound::v$id configure -gate 0 
		after 1 [list sound::v$id configure -freq $freq -gate 1 -gain 0.25]
	    }
	}
	- {
	    sound::v$id configure -gate 0
	}
    }
}
