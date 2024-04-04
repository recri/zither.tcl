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
package require ::presets
package require ::evdev

# data in the menu

namespace eval ::window {

    array set defaults { 
	tonic C
	mode Ionian
	frets 13
	strings 6
	nut 0
	octave C4
	tuning {0 5 5 5 4 5}
	root E2
	preset guitar-6
    }

    proc adjust {w which {redraw 1}} {
	# puts "adjust $w $which $redraw (which is $::window::data($which))"
	# okay, so these winfo calls allow the global touch coordinates to be mapped
	# into the window coordinates
	#puts "winfo geometry $w.t  => [winfo geometry $w.t]"
	#puts "winfo geometry $w.c  => [winfo geometry $w.c]"
	#puts "winfo rootx $w.c [winfo rootx $w.c] winfo rooty $w.c [winfo rooty $w.c]"
	#puts "winfo width $w.c [winfo width $w.c] winfo height $w.c [winfo height $w.c]"
	
	# the fretboard is a rectangle of "buttons" frets wide and strings high
	# which has a tuning specified by the root note in the lower left corner
	switch $which {
	    frets {	# the number of frets on the fretboard
	    }
	    strings {	# the number of strings on the fretboard
	    }
	    root {	# the note of the open string at bottom/closest to player
	    }
	    tuning {	# the intervals between strings starting from the root
	    }
	    tonic {	# the tonic is the note which is the root of the scale
	    }
	    mode {	# the mode determines which scale is labelled from the root
	    }
	    nut {	# nut shifts the whole fretboard by semitones
	    }
	    preset {	# presets define frets, strings, root, and tuning
		# puts "preset $::window::data(preset) -> [::presets::value $::window::data(preset)]"
		foreach {key val} [::presets::value $::window::data(preset)] {
		    set ::window::data($key) $val
		}
		adjust $w $key 0
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
	set fwid [expr {$cwid/double($::window::data(frets))}]
	set shgt [expr {$chgt/double($::window::data(strings))}]
	set keynote [::midi::name-to-note $::window::data(tonic)]
	set scalenotes [lmap n [::midi::get-mode $::window::data(mode)] {expr {($keynote+$n)%12}}]

	
	set ::window::data(cwid) $cwid
	set ::window::data(chgt) $chgt
	set ::window::data(fwid) $fwid
	set ::window::data(shgt) $shgt
	
	set in 4
	set x0 $in
	set y0 $in
	set xm [expr {$fwid/2.0}]
	set ym [expr {$shgt/2.0}]
	set xc [expr {$fwid-$in}]
	set yc [expr {$shgt-$in}]
		
	set button [list $x0 $y0 $x0 $ym $x0 $yc $xm $yc $xc $yc $xc $ym $xc $y0 $xm $y0]

	if {{MyButtonFont} ni [font names]} {
	    font create MyButtonFont {*}[font configure TkHeadingFont] -size 16
	}

	array unset ::window::stringnote

	for {set string 0} {$string < $::window::data(strings)} {incr string} {
	    set y [expr {$chgt-($string+0.5)*$shgt}]
	    # $w.c create line 0 $y $cwid $y -fill white -tag string
	    set y [expr {$y-$shgt*0.5}]
	    if {$string == 0} {
		set ::window::stringnote($string) [expr {[::midi::name-octave-to-note $::window::data(root)]+$::window::data(nut)}]
	    } else {
		set previous [expr {$string-1}]
		# puts "string $string previous $previous tuning {$::window::data(tuning)}"
		set ::window::stringnote($string) [expr {$::window::stringnote($previous)+[lindex $::window::data(tuning) $string]}]
	    }
	    for {set fret 0} {$fret < $::window::data(frets)} {incr fret} {
		set x [expr {$fret*$fwid}]
		# redraw fret
		# if {$string == 0} { $w.c create line $x 0 $x $chgt -fill white -tag fret }
		# redraw button
		# $w.c create oval $x $y [expr {$x+$fwid}] [expr {$y+$shgt}] -outline white -fill {}
		set xc [expr {$x+$fwid}]
		set yc [expr {$y+$shgt}]
		set p [$w.c create polygon $button -outline white -fill {} -smooth true]
		$w.c move $p $x $y
		# label button
		set l [$w.c create text [expr {$x+0.5*$fwid}] [expr {$y+0.5*$shgt}] -text "$string.$fret" -anchor c -fill white -font MyButtonFont]
		# label with notes
		set note [expr {$::window::stringnote($string)+$fret}]
		if {[lsearch -exact -integer $scalenotes [expr {$note % 12}]] >= 0} {
		    $w.c itemconfigure $l -text [::midi::note-to-name $note]
		    if {$keynote == ($note % 12)} {
			$w.c itemconfigure $p -width 5 -outline white
		    } else {
			$w.c itemconfigure $p -width 2 -outline grey
		    }
		} else {
		    $w.c itemconfigure $l -text {}
		    $w.c itemconfigure $p -outline darkgrey -width 1
		}
	    }
	}
    }
    
    proc note {action id x y} {
	# set s [expr {($::window::data(chgt)-$y)/$::window::data(shgt)}]
	# set f [expr {$x/$::window::data(fwid)}]
	set is [expr {int(($::window::data(chgt)-$y)/$::window::data(shgt))}]
	set if [expr {int($x/$::window::data(fwid))}]
	# set fs [expr {$s-$is}]
	# set ff [expr {$f-$if}]
	set spart $::window::stringnote($is)
	set fpart [expr {int($x/$::window::data(fwid))}]
	set freq [midi::mtof [expr {$spart+$fpart}]]
	# puts "note $action $id $x $y $s $f [::midi::note-to-name-octave $note]"
	::sound::note $action $id $freq
    }

    proc max-width {list} {
	tcl::mathfunc::max {*}[lmap i $list {string length $i}]
    }

    proc main {w} {
	# canvas fretboard
	pack [canvas $w.c] -side top -fill both -expand true
	
	# controls
	toplevel $w.t
	wm withdraw $w.t
	
	# set default values, first time
	array set ::window::data [array get ::window::defaults]
	
	# spinbox of keys
	set keys [::midi::get-keys]
	set width [max-width $keys]
	pack [labelframe $w.t.key -text {Tonic}] -side top -fill x -expand true
	pack [spinbox $w.t.key.spin -textvariable ::window::data(tonic) -width $width -values $keys -command [list ::window::adjust $w tonic]]
	
	# spinbox of modes
	set modes [::midi::get-modes]
	set width [max-width $modes]
	pack [labelframe $w.t.mode -text {Mode}] -side top -fill x -expand true
	pack [spinbox $w.t.mode.spin -textvar ::window::data(mode) -width $width -values $modes -command [list ::window::adjust $w mode]]
	
	# spinbox of nut semitone offsets from specified preset
	set width 3
	pack [labelframe $w.t.nut -text {Nut}] -side top -fill x -expand true
	pack [spinbox $w.t.nut.spin -textvariable ::window::data(nut) -width $width -from -12 -to 12 -value 0 -command [list ::window::adjust $w nut]]
	
	# spinbox of frets
	pack [labelframe $w.t.frets -text {Frets}] -side top -fill x -expand true
	pack [spinbox $w.t.frets.spin -textvar ::window::data(frets) -width 2 -from 8 -to 26 -increment 2 -command [list ::window::adjust $w frets]]
	
	# menu of presets
	# FIX.ME - go to multi level menu
	set presets [::presets::keys]
	set width [max-width $presets]
	pack [labelframe $w.t.preset -text {Preset}] -side top -fill x -expand true
	pack [menubutton $w.t.preset.menu -textvar ::window::data(preset) -width $width -menu $w.t.preset.menu.m]
	menu $w.t.preset.menu.m -tearoff no
	foreach preset $presets {
	    $w.t.preset.menu.m add radiobutton -label $preset -variable ::window::data(preset) -value $preset -command [list ::window::adjust $w preset]
	}

	# set default values
	array set ::window::data [array get ::window::defaults]
	
	# control buttons
	pack [button $w.t.done -text Dismiss -command [list wm withdraw $w.t]] -side top -fill x -expand true
	pack [button $w.t.quit -text Quit -command {destroy .}] -side top -fill x -expand true
	pack [button $w.t.panic -text Panic -foreground red -command {stop sound}] -side top -fill x -expand true
	
	bind $w.c <Configure> [list ::window::redraw  $w]
	bind $w.c <Button-3> [list wm deiconify $w.t]

	bind $w.c <<TouchBegin>> {::window::note + %d %x %y}
	bind $w.c <<TouchUpdate>> {::window::note . %d %x %y}
	bind $w.c <<TouchEnd>> {::window::note - %d %x %y}

	bind $w.c <ButtonPress-1> {::window::note + f %x %y}
	bind $w.c <B1-Motion> {::window::note . f %x %y}
	bind $w.c <ButtonRelease-1> {::window::note - f %x %y}
    }
}
