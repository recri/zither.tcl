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

package provide midi 1.0

namespace eval ::midi {

    ##
    ## names for midi note numbers
    ##
    array set notes {
	lowest			0
	lowest_piano		21
	lowest_bass_clef	43
	highest_bass_clef	57
	middle_C		60
	lowest_treble_clef	64
	A_440			69
	highest_treble_clef	77
	highest_piano		108
	highest			127
    
	C	60
	C#	61
	Db	61
	D	62
	D#	63
	Eb	63
	E	64
	F	65
	F#	66
	Gb	66
	G	67
	G#	68
	Ab	68
	A	69
	A#	70
	Bb	70
	B	71

	octave-sharp {C C# D D# E F F# G G# A A# B}
	octave-flat  {C Db D Eb E F Gb G Ab A Bb B}
    }

    set enharmonics [dict create {*}{
	B# 0 C 0 
	C# 1 Db 1 
	D 2 
	D# 3 Eb 3 
	E 4 Fb 4
	E# 5 F 5 
	F# 6 Gb 6
	G 7
	G# 8 Ab 8
	A 9
	A# 10 Bb 10
	B 11 Cb 11
    }]

    ##
    ## keys in cycle of fifths order
    ## with semitone offset from C
    ##
    set keys [dict create {*}{
	Gb 6 Db 1 Ab 8 Eb 3 Bb 10 F 5 C 0 G 7 D 2 A 9 E 4 B 11 F# 6 C# 1
    }]

    set keyisflat [dict create {*}{
	Gb 1 Db 1 Ab 1 Eb 1 Bb 1 F 1 C 0 G 0 D 0 A 0 E 0 B 0 F# 0 C# 0
    }]

    ##
    ## synonymous key names
    ##
    set keysyn [dict create {*}{
	Gb F#   F# Gb   Db C#   C# Db
    }]
    ##
    ## modern modes, names and displacements from root
    ##
    set modes [dict create {*}{
	Ionian     {0 2 4 5 7 9 11 12}
	Dorian     {0 2 3 5 7 9 10 12}
	Phrygian   {0 1 3 5 7 8 10 12}
	Lydian     {0 2 4 6 7 9 11 12}
	Mixolydian {0 2 4 5 7 9 10 12}
	Aeolian    {0 2 3 5 7 8 10 12}
	Locrian    {0 1 3 5 6 8 10 12}
    }]

    ##
    ## octaves note name and semitone offset from middle_C
    ##
    set octaves [dict create {*}{
	C-1 -60 C0 -48 C1 -36 C2 -24 C3 -12 C4 0 C5 12 C6 24 C7 36 C8 48 C9 60
    }]

    ##
    ## midi translations
    ##

    # compute the standard frequency of a midi note number
    proc note-to-hertz {note} { return [expr {440.0 * pow(2, ($note-$::midi::notes(A_440))/12.0)}] }

    # precompute the result
    variable cache-note-to-hertz {}
    for {set note $notes(lowest)} {$note <= $notes(highest)} {incr note} {
	lappend cache-note-to-hertz [note-to-hertz $note]
    }

    # convert a midi note into a frequency in Hertz
    proc mtof {note} { lindex ${::midi::cache-note-to-hertz} $note }
    
    # compute a note name of a midi note number, and vice versa
    # the second translates both flatted and sharped notes
    proc note-to-name {note {key C}} { 
	if {[dict get $::midi::keyisflat $key]} {
	    return [lindex $::midi::notes(octave-flat) [expr {$note%12}]] 
	} else {
	    return [lindex $::midi::notes(octave-sharp) [expr {$note%12}]] 
	}
    }
    proc name-to-note {name} { dict get $::midi::enharmonics $name }

    # compute the standard octave of a midi note number
    proc note-to-octave {note} { return [expr {($note/12)-1}] }
    proc octave-to-note {octave} { return [expr {($octave+1)*12}] }

    # put the two above together
    proc note-to-name-octave {note {key C}} { return "[note-to-name $note $key][note-to-octave $note]" }
    proc name-octave-to-note {name} {
	if {[regexp {^([A-G][\#b]?)(|-?\d+)$} $name all note octave sharp]} {
	    return [expr {[octave-to-note $octave]+[name-to-note $note$sharp]}]
	}
	error "$name did not match regexp"
    }

    # translate a midi velocity to a level
    proc velocity-to-level {velocity} {
	return [expr {$velocity / 127.0}]
    }

    variable cache-velocity-to-level {}
    for {set m 0} {$m < 128} {incr m} {
	lappend cache-velocity-to-level [velocity-to-level $m]
    }

    proc vtol {vel} { lindex ${::midi::cache-velocity-to-level} $vel }

    variable testing 1
    
    if {$testing} {
	for {set note $notes(lowest)} {$note <= $notes(highest)} {incr note} {
	    set name [note-to-name-octave $note]
	    set note2 [name-octave-to-note $name]
	    if {$note != $note2} { error "failed round trip note-to-name-octave and back $note $name $note2" }
	}
	for {set v 0} {$v <= 127} {incr v} {
	    set l [vtol $v]
	    if {$l < 0 || $l > 1} { error "vtol out of range $v => $l" }
	}
	foreach key [dict keys $keys] {
	    set name [note-to-name [dict get $keys $key]]
	    if {$key ne $name} {
		if {$key ni {Gb Eb Db Bb Ab F# D# C# B A#}} {
		    error "key name didn't match key name of key note $key => $name"
		}
	    }
	}
    }
}

proc ::midi::get-keys {} { dict keys $::midi::keys }
proc ::midi::get-key {key} { dict get $::midi::keys $key }

proc ::midi::get-octaves {} { dict keys $::midi::octaves }
proc ::midi::get-octave {octave} { dict get $::midi::octaves $octave }

proc ::midi::get-modes {} { dict keys $::midi::modes }
proc ::midi::get-mode {mode} { dict get $::midi::modes $mode }
