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
	strings 6
	tuning guitar-6
    }

    proc adjust {w which} {
	puts "adjust $w $which (which is $::window::data($which))"
	# okay, so these winfo calls allow the global touch coordinates to be mapped
	# into the window coordinates
	#puts "winfo geometry $w.t  => [winfo geometry $w.t]"
	#puts "winfo geometry $w.c  => [winfo geometry $w.c]"
	#puts "winfo rootx $w.c [winfo rootx $w.c] winfo rooty $w.c [winfo rooty $w.c]"
	#puts "winfo width $w.c [winfo width $w.c] winfo height $w.c [winfo height $w.c]"
	
	# the fretboard is a rectangle of "buttons" frets wide and strings high
	# which has a tuning specified by the root note in the lower left corner
	switch $which {
	    key {
		# the key determines which note is the root of the scale
	    }
	    mode {
		# the mode determines which scale is labelled from the root
	    }
	    frets {
		# frets determines the width of the fretboard
	    }
	    tuning {
		# tuning specifies the number of strings and what pitch they're tuned to
		# the following is not always true, there are | marking groups of strings
		# and some strings are unfretted drones or accompaniment
		# 
		set ::window::data(strings) [llength $::window::data(tuning)];
	    }
	    octave {
		# octave shifts the whole fretboard up or down by 12 semitones
		# it actually has no effect on the fretboard at all, only on the 
		# frequencies of the notes played
	    }
	    default {
		error "no case for $which in adjust"
	    }
	}
	redraw $w
    }

    proc redraw {w} {
	$w.c delete all
	set cwid [winfo width $w.c]
	set chgt [winfo height $w.c]
	set fwid [expr {$cwid/$::window::data(frets)}]
	set shgt [expr {$chgt/$::window::data(strings)}]
		       
	for {set string 0} {$string < $::window::data(strings)} {incr string} {
	    set y [expr {$string*$shgt+$shgt/2.0}]
	    $w.c create line 0 $y $cwid $y -fill white -tag string
	}
	for {set fret 0} {$fret < $::window::data(frets)} {incr fret} {
	    set x [expr {$fret*$fwid}]
	    $w.c create line $x 0 $x $chgt -fill white -tag fret
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
	pack [spinbox $w.t.key -textvariable ::window::data(key) -width $width -values $keys -command [list ::window::adjust $w key]] -side left
	
	# spinbox of modes
	set modes [::midi::get-modes]
	set width [max-width $modes]
	pack [label $w.t.modelabel -text {Mode:}] -side left
	pack [spinbox $w.t.mode -textvar ::window::data(mode) -width $width -values $modes -command [list ::window::adjust $w mode]] -side left
	
	# spinbox of octaves
	set octaves [::midi::get-octaves]
	set width [max-width $octaves]
	pack [label $w.t.octavelabel -text {Octave:}] -side left
	pack [spinbox $w.t.octave -textvariable ::window::data(octave) -width $width -values $octaves -command [list ::window::adjust $w octave]] -side left
	
	# spinbox of frets
	pack [label $w.t.fretslabel -text {Frets:}] -side left
	pack [spinbox $w.t.frets -textvar ::window::data(frets) -width 2 -from 8 -to 26 -increment 2 -command [list ::window::adjust $w frets]] -side left
	
	# menu of tunings
	set tunings [::midi::get-tunings]
	set width [max-width $tunings]
	pack [label $w.t.tunelabel -text {Tuning:}] -side left
	pack [menubutton $w.t.tuning -textvar ::window::data(tuning) -width $width -menu .t.tuning.m] -side left
	menu $w.t.tuning.m -tearoff no
	foreach tuning $tunings {
	    $w.t.tuning.m add radiobutton -label $tuning -variable ::window::data(tuning) -value $tuning -command [list ::window::adjust $w tuning]
	}

	# set default values
	array set ::window::data [array get ::window::defaults]
	
	# control buttons to the right edge
	pack [button $w.t.quit -text Quit -command {destroy .}] -side right
	pack [button $w.t.panic -text Panic -foreground red -command {stop sound}] -side right
	
	redraw $w
    }
}
