package provide sound 1.0

package require sdrtcl::jack-client

namespace eval sound {
    variable data
    array set data {
	sound ks
	factory faust::pm::ks
	n 0
	1/1 1.0
	1/2 0.5
	1/3 0.333
	1/4 0.25
	1/5 0.20
	1/6 0.167
	1/7 0.143
	1/8 0.125
	1/9 0.111
	1/10 0.10
    }
}

namespace eval synth {
}

# get a jack client to manipulate the server
sdrtcl::jack-client sound::jack

# puts [::sound::jack list-ports]

proc ::sound::note {action id freq} {
    set command synth::$::sound::data(sound)$id
    if {[info commands $command] eq {}} {
	$::sound::data(factory) $command
	sound::jack connect $command:out_0 system:playback_1
	sound::jack connect $command:out_0 system:playback_2
	#puts "$::sound::data(factory) $command"
    }
    switch -exact $action {
	+ {
	    $command configure -freq $freq -gate 1 -gain $::sound::data(1/[incr ::sound::data(n)])
	}
	. { 
	    # this is the lazy bend/glide, just hop to the next string or fret
	    if {[$command cget -freq] != $freq} { 
		# $command configure -gate 0 
		# after 1 [list 
		$command configure -freq $freq -gate 1 -gain $::sound::data(1/[set ::sound::data(n)])
		#]
	    }
	}
	- {
	    $command configure -gate 0
	    incr ::sound::data(n) -1
	}
    }
}

proc ::sound::stop {} {
    foreach command [info commands ::synth::*] {
	$command -gate 0 -gain 0
    }
}

# harpsichord is really loud
# ks broke the sound system once, not sure how
set ::sound::sounds [dict create {*}{
    elecGuitar faust::pm::elecGuitar
    guitar faust::pm::guitar
    ks faust::pm::ks
    marimba faust::pm::marimba
    modularInterpInst faust::pm::modularInterpInst
    nylonGuitar faust::pm::nylonGuitar
    violin faust::pm::violin
    bass faust::stk::bass
    bowed faust::stk::bowed
    harpsi faust::stk::harpsi
    modalBar faust::stk::modalBar
    piano faust::stk::piano
    sitar faust::stk::sitar
    tibetanBowl faust::stk::tibetanBowl
    tunedBar faust::stk::tunedBar
}]

proc ::sound::list-sounds {} {
    dict keys $::sound::sounds
}

proc ::sound::select {sound} {
    # should probably set the maximum gain per instrument
    # and correct the table of weights
    set ::sound::data(sound) $sound
    set ::sound::data(factory) [dict get $::sound::sounds $sound]
    if {[info commands $::sound::data(factory)] eq {}} {
	package require $::sound::data(factory)
    }
}

sound::select guitar
