package provide sound 1.0

package require sdrtcl::jack-client

namespace eval sound {
    variable data
    array set data {
	sound ks
	factory faust::pm::ks
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
	puts "$::sound::data(factory) $command"
    }
    switch -exact $action {
	+ {
	    $command configure -freq $freq -gate 1 -gain 0.25
	}
	. { 
	    #if {[sound::v$id cget -freq] != $freq} { 
	    #sound::v$id configure -gate 0 
	    #after 1 [list sound::v$id configure -freq $freq -gate 1 -gain 0.25]
	    #}
	}
	- {
	    $command configure -gate 0
	}
    }
}

proc ::sound::stop {} {
    foreach command [info commands ::synth::*] {
	$command -gate 0 -gain 0
    }
}

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
    set ::sound::data(sound) $sound
    set ::sound::data(factory) [dict get $::sound::sounds $sound]
    if {[info commands $::sound::data(factory)] eq {}} {
	package require $::sound::data(factory)
    }
}

sound::select guitar
