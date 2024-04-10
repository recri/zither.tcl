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

#
# this isn't really useful as it is, I've been experimenting with different
# organizations and this is just a compendium or things people say
#
# the guitar tunings in particular, most of the tunings should be converted
# to interval + root because they're all the same
#
# various conventions for guitar tunings, upper case for octave 2 notes,
# lower case for octave 3, lower case' for octave 4.  standard EADgbe'
#

#
# this could be the raw input, since I can compute the preset components
# from this.  Maybe you navigate the tree?  Use the list of keys as the
# name?
#
# What isn't here, yet, is the fretting details.  A dulcimer doesn't 
# traditionally have chromatic fretting, and other instruments have
# no frets at all.  So this should be incorporated into the preset
# information for an instrument, even though the number of frets is
# not so easy to specify since the size of the screen and the touch resolution
# pretty much sets that.
#

package provide rawtuning 1.0

package require midi

namespace eval ::rawtuning {
    set flat {♭}
    set sharp {♯}
    set dash {–}
    # these are the chromatic offsets of the traditional frets
    # repeat to 3rd and 4th above second octave
    set dulcimer-frets {0 2 4 5 7 9 10 11 12}

    set defaults [dict create {*}{
	frets chromatic
	strings single
	comment {}
    }]
    set tunings [dict create {*}{
	banjo {
	    4  {
		plectrum {C3 G3 B3 D4}
		chicago {D3 G3 B3 E4}
		tenor {C3 G3 D4 A4}
	    }
	    5 {
		frets 5-string-banjo
		standard {G4 C3 G3 B3 D4}
		open-G {G4 D3 G3 B3 D4}
		open-G-alt {G4 C3 G3 B3 D4}
		double-C {G4 C3 G3 C4 D4}
		sawmill {G4 D3 G3 C4 D4}
		open-D {F#4 D3 F#3 A3 D4} 
		double-D {A4 D3 A3 D4 E4}
		open-A {A4 E3 A3 C#4 E4}
	    }
	}
	bass-guitar {
	    4 {
		standard {E1 A1 D2 G2}
	    }
	    5 {
		low {B0 E1 A1 D2 G2}
		high {E1 A1 D2 G2 C3}
	    }
	    6 {
		low {B0 E1 A1 D2 G2 C3}
		high {E1 A1 D2 G2 C3 F3}
	    }
	}
	bass-viol {
	    frets continuous
	    standard {E1 A1 D2 G2}
	}
	cello {
	    frets continuous
	    standard {C2 G2 D3 A3}
	}
	dulcimer {
	    3 {
		frets dulcimer
		traditional-1 {G3 G3 C3}
		traditional-2 {C4 G3 C3}
		traditional-3 {C4 F3 C3}
		modern-1 {A3 A3 D3}
		modern-2 {D4 A3 D3}
		modern-3 {D4 G3 D3}
	    }
	    4 {
		frets dulcimer
		traditional-1 {G3 G3 G3 C3}
		traditional-2 {C4 C4 G3 C3}
		traditional-3 {C4 C4 F3 C3}
		modern-1 {A3 A3 A3 D3}
		modern-2 {D4 D4 A3 D3}
		modern-3 {D4 D4 G3 D3}
	    }
	}
	guitar {
	    6 {
		standard {E2 A2 D3 G3 B3 E4}
		drop-D {D2 A2 D3 G3 B3 E4}
		double-drop-D {D2 A2 D3 G3 B3 D4}
		lowered-Eb {Eb2 Ab2 Db3 Gb3 Bb3 Eb4}
		lowered-D {D2 G2 C3 F3 A3 D4}
		EADGBE {E2 A2 D3 G3 B3 E4}
		EADGCF {E2 A2 D3 G3 C4 F4}
		{EG#CEG#C} {E2 G#2 C3 E3 G#3 C4}
		CGDAEB {C2 G2 D3 A3 E4 B4}
		{EBEG#BE} {E2 B2 E3 G#3 B3 E4}
		{DADF#AD} {D2 A2 D3 F#3 A3 D4}
		DADGAG {D2 A2 D3 G3 A3 G4}
		DGCGCD {D2 G2 C3 G3 C4 D4}
		CGDGAD {C2 G2 D3 G3 A4 D4}
		EEEEBE {E2 E2 E3 E3 B3 E4}
		EEBBBE {E2 E2 B3 B3 B3 E4}
		EBDGAD {E2 B2 D3 G3 A4 D4}
		DGDGBD {D2 G2 D3 G3 B3 D4}
		{EBEG#BE} {E2 B2 E3 G#3 B3 E4}
		CGCGCE {C2 G2 C3 G3 C4 E4}
	    }
	    7  {
		russian {D2 G2 B2 D3 G3 B3 D4}
	    }
	    10 {
		concat {E1 A1 D2 G2 E2 A2 D3 G3 B3 E4}
	    }
	    12 {
		strings paired
		standard {E1 E2 A1 A2 D2 D3 G2 G3 B3 B3 E4 E4}
	    }
	}
	lyre {
	    7 {
		frets none
		standard {D4 E4 G4 A4 B4 D5 E5}
	    }
	    16 {
		frets none
		standard {G3 A3 B3 C4 D4 E4 F4 G4 A4 B4 C5 D5 E5 F5 G5 A5}
	    }
	}
	mandolin {
	    strings paired
	    standard     {G3 G3 D4 D4 A4 A4 E5 E5}
	    cajun        {F3 F3 C4 C4 G4 G4 D5 D5}
	    open-G       {G3 G3 D4 D4 G4 G4 B4 B4}
	    sawmill      {G3 G3 D4 D4 G4 G4 D5 D5}
	    geedad       {G3 G3 D4 D4 A4 A4 D5 D5}
	    open-D       {D3 D3 D4 D4 A4 A4 D5 D5}
	    high-bass    {A3 A3 D4 D4 A4 A4 E5 E5}
	    cross-tuning {A3 A3 E4 E4 A4 A4 E5 E5}
	    open-A       {A3 A3 E4 E4 A4 A4 C#5 C#5 }
	    
	}
	stick {
	    8 {
		1 {B0 E1 A1 D2 G2 C3 F3 Bb3}
		2 {B0 E1 A1 D2 G2 C3 E3 A3}
		3 {B0 E1 A1 D2 G2 B2 E3 A3}
		4 {A2 D2 G1 C1 E2 A2 D3 G3}
		5 {A2 D2 G1 C1 F#2 B2 E3 A3}
	    }
	    10 {
		1 {E3 A2 D2 G1 C1 E2 A2 D3 G3 C4}
		2 {E3 A2 D2 G1 C1 F#2 B2 E3 A3 D4}
		3 {E3 A2 D2 G1 C1 C#2 F#2 B2 E3 A3}
		4 {E3 A2 D2 G1 C1 B1 E2 A2 D3 G3}
		5 {D3 G2 C2 F1 Bb0 D2 G2 C3 F3 Bb3}
		6 {F#3 B2 E2 A1 D1 F#2 B2 E3 A3 D4}
		7 {F#3 B2 E2 A1 D1 C#2 F#2 B2 E3 A3}
		8 {D#3 G#2 C#2 F#1 B0 E2 A2 D3 G3 C4}
	    }
	    12 {
		1 {B3  E3  A2  D2 G1  C1  B1  E2  A2 D3 G3 C4}
		2 {B3  E3  A2  D2 G1  C1  C#2 F#2 B2 E3 A3 D4}
		3 {A3  E3  A2  D2 G1  C1  B1  E2  A2 D3 G3 C4}
		4 {A3  E3  A2  D2 G1  C1  C#2 F#2 B2 E3 A3 D4}
		5 {A3  D3  G2  C2 F1  Bb0 A1  D2  G2 C3 F3 Bb3}
		6 {C#4 F#3 B2  E2 A1  D1  C#2 F#2 B2 E3 A3 D4}
		7 {A#3 D#3 G#2 C#2 F#1 B0  E1  A1 D2 G2 C3 F3}
	    }
	}
	ukulele {
	    pocket {D5 G4 B4 E5}
	    pocket-alt {C5 F4 A4 D5}
	    soprano {G4 C4 E4 A4}
	    soprano-alt-1 {A4 D4 F#4 B4}
	    soprano-alt-2 {G3 C4 E4 A4}
	    concert {G4 C4 E4 A4}
	    concert-alt {G3 C4 E4 A4}
	    tenor {G4 C4 E4 A4}
	    tenor-alt-1 {D4 G3 B3 E4}
	    tenor-alt-2 {A3 D4 F#4 }
	    tenor-alt-3 {D3 G3 B3 E4}
	    baritone {D3 G3 B3 E4}
	    baritone-alt {C3 G3 B3 E4}
	    bass {E1 A1 D2 G2}
	    bass-alt {D1 A1 D2 G2}
	}
	viola {
	    frets continuous
	    standard {C3 G3 D4 A4}
	}
	violin {
	    frets continuous
	    standard     {G3 D4 A4 E5}
	    cajun        {F3 C4 G4 D5}
	    open-G       {G3 D4 G4 B4}
	    sawmill      {G3 D4 G4 D5}
	    gee-dad      {G3 D4 A4 D5}
	    dead-man     {D4 D4 A4 D5}
	    high-bass    {A3 D4 A4 E5}
	    cross-tuning {A3 E4 A4 E5}
	    calico       {A3 E4 A4 C#5}
	    old-sledge   {A3 E4 A4 D5}
	    glory-in-the-meeting-House {E3 D4 A4 E5}
	    get-up-in-the-cool {E4 E4 A4 E5}
	}
	zither {
	    frets zither
	    strings zither
	    comment {
		The first five strings are fretted, and you can see the dulcimer there.
		The rest of the strings are unfretted.  The first group is 'accompaniment',
		the second group is 'bass', and the third group is 'contrabass.  The sixth
		group contains strings that are added to the concert zither to make an alpine
		zither.
		I forgot to look, but I expect they are chromatically fretted.
	    }
	    38 {
		viennese {A4 D4 G4 G3 C3 Ab4 Eb4 Bb3 F4 C4 G4 D4 A3 E4 B3 F#4 C#4 G#3 Eb2 Bb2 F2 C3 G2 D2 A2 E2 B2 F#2 C#2 G#2 C2 B1 Bb1 A1 G#1 G1 F#1 F1}
	    }
	    42 {
		munich {A4 A4 D4 G3 C3 | Eb4 Bb3 F4 C4 G3 D4 A3 E4 B3 F#3 C#4 G#3 | Eb3 Bb2 F3 C3 G2 D3 A2 E3 B2 F#2 C#3 G#2 | F2 E2 Eb2 D2 C#2 C2 | B1 Bb1 A1 G#1 G1 F#1 F1}
	    }
	}
	15/14-hammered-dulcimer {
	    frets none
	    strings hammered-dulcimer
	    comment { this tuning is in semi-tone intervalsis complicated, go look it up }
	    standard {0 2 4 5 7 9 10 12 14 15 17 19 20 22 | 6 7 9 11 12 14 16 17 19 21 22 24 26 27 29 | 13 14 16 18 19 21 23 24 26 28 29 31 33 34 36 38}
	}
    }]
}

proc ::rawtuning::keys-dict {} {dict keys $::rawtuning::tunings}
proc ::rawtuning::get-dict {args} {dict get $::rawtuning::tunings {*}$args}

proc ::rawtuning::instruments {} {
    set inst {}
    foreach i [dict keys $rawtuning::tunings] {
	set strings {}
	foreach s [dict keys [dict get $rawtuning::tunings $i]] {
	    if {[string is integer $s] && [string is list [dict get $rawtuning::tunings $i $s]]} {
		lappend strings $s
	    }
	}
	if {$strings ne {}} {
	    foreach s $strings { lappend inst [list $i $s] }
	} else {
	    lappend inst $i
	}
    }
    return $inst
}

proc ::rawtuning::instrument {inst} {
    set instrument $rawtuning::defaults
    dict for {key val} [dict get $rawtuning::tunings {*}$inst] {
	if {[dict exists $instrument $key]} {
	    dict set instrument $key $val; # override default value
	} else {
	    dict set instrument tuning $key $val
	}
    }
    return $instrument
}

if {1} {
    foreach i [::rawtuning::instruments] {
	puts "$i -> [::rawtuning::instrument $i]"
    }
}

# munich zither fretted a a d g c (a == 440)
# accompaniment eb bb f c g d a e b f# c# g#
# bass Eb Bb F C G D A E B F# C# G#
# contrabass F E Eb D C# C B Bb A G# G F# FF		 

#
# take tunings as lists of notename octaves
# and other formats to be determined, and 
# translate to preset format:
# tuning - the set of intervals between strings
# root - the open note of the string closest to the player
# strings - the number of strings
#
proc ::rawtuning::to-preset {key value} {
    # puts "$key $value" 
    set strings [llength $value]
    set root [lindex $value 0]
    set tuning {}
    set notes [lmap note $value {::midi::name-octave-to-note $note}]
    for {set i 0} {$i < $strings} {incr i} {
	if {$i == 0} { 
	    set interval 0
	} else {
	    set interval [expr {[lindex $notes $i]-[lindex $notes $i-1]}]
	}
	lappend tuning $interval
    }
    if {0} {
	switch -regexp $tuning {
	    {^0( +4)+$} { set tuning thirds }
	    {^0( +5)+$} { set tuning fourths }
	    {^0( +7)+$} { set tuning fifths }
	    {^0 +0( +7 +0)+$} { set tuning doubled-fifths }
	}
    }
    set notes2 {}
    foreach interval $tuning {
	if {$notes2 eq {}} {
	    set note2 $root
	} else {
	    set note2 [::midi::note-to-name-octave [expr {$interval+[::midi::name-octave-to-note [lindex $notes2 end]]}]]
	}
	lappend notes2 $note2
    }
    # foreach n1 $value n2 $notes2 { if {$n1 ne $n2} { error "mismatch between $value and $notes2" } }
    return "$key { strings $strings root $root tuning {$tuning}}"
}

