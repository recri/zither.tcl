# -*- mode: Tcl; tab-width: 8; -*-
#
# Copyright (C) 2024 by Roger E Critchlow Jr, Las Cruces, NM, USA
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
# 

package provide ::window 1.0

package require ::params
package require ::midi
package require ::evdev

# data in the menu

namespace eval ::window {
    array set defaults { 
	key C
	mode Ionian
	frets 14
	octave C4
	tuning guitar-6
    }

    proc adjust {which} {
	puts "adjust $which $::window::data($which)"
	switch $which {
	    key {
	    }
	    mode {
	    }
	    fret {
	    }
	    tuning {
	    }
	    octave {
	    }
	    default {
		error "no case for $which in adjust"
	    }
	}
    }

    proc max-width {list} {
	tcl::mathfunc::max {*}[lmap i $list {string length $i}]
    }

    proc main {w} {

	# menu bar
	pack [frame $w.t] -side top -fill x
	
	# canvas fretboard
	pack [canvas $w.c] -side top -fill both -expand true
	
	# spinbox of keys
	set keys [::midi::get-keys]
	set width [max-width $keys]
	pack [label $w.t.keylabel -text {Key:}] -side left
	pack [spinbox $w.t.key -textvariable ::window::data(key) -width $width -values $keys -command {::window::adjust key}] -side left
	
	# spinbox of modes
	set modes [::midi::get-modes]
	set width [max-width $modes]
	pack [label $w.t.modelabel -text {Mode:}] -side left
	pack [spinbox $w.t.mode -textvar ::window::data(mode) -width $width -values $modes -command {::window::adjust mode}] -side left
	
	# spinbox of octaves
	set octaves [::midi::get-octaves]
	set width [max-width $octaves]
	pack [label $w.t.octavelabel -text {Octave:}] -side left
	pack [spinbox $w.t.octave -textvariable ::window::data(octave) -width $width -values $octaves -command {::window::adjust octave}] -side left
	
	# spinbox of frets
	pack [label $w.t.fretslabel -text {Frets:}] -side left
	pack [spinbox $w.t.frets -textvar ::window::data(frets) -width 2 -from 8 -to 26 -increment 2 -command {::window::adjust frets}] -side left
	
	# menu of tunings
	set tunings [::midi::get-tunings]
	set width [max-width $tunings]
	pack [label $w.t.tunelabel -text {Tuning:}] -side left
	pack [menubutton $w.t.tuning -textvar ::window::data(tuning) -width $width -menu .t.tuning.m] -side left
	menu $w.t.tuning.m -tearoff no
	foreach tuning $tunings {
	    $w.t.tuning.m add radiobutton -label $tuning -variable ::window::data(tuning) -value $tuning -command {::window::adjust tuning}
	}

	# set default values
	array set ::window::data [array get ::window::defaults]
	
	# control buttons to the right edge
	pack [button $w.t.quit -text Quit -command {destroy .}] -side right
	pack [button $w.t.panic -text Panic -foreground red -command {stop sound}] -side right
    }
}
