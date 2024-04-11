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

package provide window 1.0

package require params
package require touch
package require midi
package require instrument
# package require presets
package require evdev
package require sound

namespace eval ::window {
    variable data
    array set ::window::data [array get ::params::defaults]
    array set ::window::data {chgt 0 cwid 0 sper 0 fper 0}
    
    proc adjust {w f which value {redraw 1}} {

	# puts "adjust $w $f $which $value $redraw -> $::window::data($which)"

	if { ! [info exists ::window::data($which)] || $::window::data($which) ne $value} {
	    set ::window::data($which) $value
	}

	# the fretboard is a rectangle of "buttons" frets wide and strings high
	# which has a tuning specified by the root note in the lower left corner
	switch $which {
	    instrument {	# the base instrument
		set ::window::data(instdict) [::instrument::get-instrument $::window::data(instrument)]
		control-rebuild-tuning $w $f
		::window::adjust $w $f tuning [lindex [::instrument::get-tunings $::window::data(instdict)] 0]
	    }
	    frets {	# the number of frets on the fretboard
	    }
	    strings {	# the number of strings on the fretboard
	    }
	    root {	# the note of the open string at bottom/closest to player
	    }
	    stringnotes {	# the midi note for each string
	    }
	    tuning {	# the notes the strings are tuned to from closest to furthest
		::window::adjust-all $w $f [::instrument::expand-tuning [::instrument::get-tuning $::window::data(instdict) $::window::data(tuning)]]
	    }
	    tonic {	# the tonic is the note which is the root of the scale
	    }
	    mode {	# the mode determines which scale is labelled from the root
	    }
	    nut {	# nut shifts the whole fretboard by semitones
	    }
	    sound {
		::sound::select $::window::data(sound)
	    }
	    fper - sper - cwid - chgt { # window and fretboard geometry
	    }
	    default {
		error "no case for $which in adjust"
	    }
	}
	if {$redraw} { redraw $f }
    }

    proc adjust-all {w f keyvals} {
	# puts "adjust-all $w $f {$keyvals}"
	if {[llength $keyvals] > 0} {
	    if {[llength $keyvals] > 2} {
		foreach {key value} [lrange $keyvals 0 end-2] { ::window::adjust $w $f $key $value 0 }
	    }
	    ::window::adjust $w $f {*}[lrange $keyvals end-1 end] 1
	}
    }
    
    proc redraw {w} {
	$w delete all
	set cwid [winfo width $w]
	set chgt [winfo height $w]
	set ::window::data(cwid) $cwid
	set ::window::data(chgt) $chgt
	set fper [expr {$chgt/double($::window::data(frets))}]
	set sper [expr {$cwid/double($::window::data(strings))}]
	set xper $sper
	set yper $fper
	set ::window::data(fper) $fper
	set ::window::data(sper) $sper

	set keynote [::midi::name-to-note $::window::data(tonic)]
	set scalenotes [lmap n [::midi::get-mode $::window::data(mode)] {expr {($keynote+$n)%12}}]
	
	set in 4
	set x0 $in
	set y0 $in
	set xm [expr {$xper/2.0}]
	set ym [expr {$yper/2.0}]
	set xc [expr {$xper-$in}]
	set yc [expr {$yper-$in}]
		
	set button [list $x0 $y0 $x0 $ym $x0 $yc $xm $yc $xc $yc $xc $ym $xc $y0 $xm $y0]

	if {{MyButtonFont} ni [font names]} {
	    font create MyButtonFont {*}[font configure TkHeadingFont] -size 16
	}

	for {set string 0} {$string < $::window::data(strings)} {incr string} {
	    set stringnote [expr {[lindex $::window::data(stringnotes) $string]+$::window::data(nut)}]
	    for {set fret 0} {$fret < $::window::data(frets)} {incr fret} {
		foreach {x y} [fret-to-window $string $fret] break;
		set xc [expr {$x+$xper}]
		set yc [expr {$y+$yper}]
		set p [$w create polygon $button -outline white -fill {} -smooth true]
		$w move $p $x $y
		# label button
		set l [$w create text [expr {$x+0.5*$xper}] [expr {$y+0.5*$yper}] -text "$string.$fret" -anchor c -fill white -font MyButtonFont]
		# label with notes
		set fretnote [expr {$stringnote+$fret}]
		$w itemconfigure $l -text [::midi::note-to-name $fretnote $::window::data(tonic)]
		if {[lsearch -exact -integer $scalenotes [expr {$fretnote % 12}]] >= 0} {
		    if {$keynote == ($fretnote % 12)} {
			# highlight the tonic
			$w itemconfigure $p -width 5 -outline white
		    } else {
			# emphasize the scale
			$w itemconfigure $p -width 2 -outline white
		    }
		} else {
		    # deemphasize the accidentals
		    $w itemconfigure $l -fill darkgrey
		    $w itemconfigure $p -width 1 -outline grey20
		}
	    }
	}
    }

    # translate touch coordinates into the window system coordinates
    # x or wayland would do this for us, but Tk doesn't handle touch
    proc touch-to-window {x y} {
	return [list $y [expr {max(0,$::window::data(chgt)-$x-1)}]]
    }	

    # translate window coordinates, x and y increasing from upper right corner
    # into string and fret
    # well, not exactly.  Translate touch input coordinates, which didn't rotate
    # with the screen when we put the touchscreen into portrait mode.
    proc touch-to-fret {x y} {
	foreach {x y} [::window::touch-to-window $x $y] break
	set s [expr {max(0,min($::window::data(strings), int($x/$::window::data(sper))))}]
	set f [expr {max(0,min($::window::data(frets), int($y/$::window::data(fper))))}]
	list $s $f
    }

    # translate string and fret coordinates into window coordinates
    # in this case, they are window coordinates, and this should be
    # orientation independent
    proc fret-to-window {string fret} {
	set y [expr {$fret*$::window::data(fper)}]
	set x [expr {$string*$::window::data(sper)}]
	list $x $y
    }
    
    # play the note
    proc note {action id x y} {
	foreach {string fret} [touch-to-fret $x $y] break
	# puts "note $action $id $x $y $string $fret"
	sound::note $action $id [midi::mtof [expr {[lindex $::window::data(stringnotes) $string]+$fret}]]
    }

    proc max-width {list} {
	tcl::mathfunc::max {*}[lmap i $list {string length $i}]
    }

    proc myscale {w f name from to} {
	labelframe $w.$name -text [string totitle $name]
	scale $w.$name.scale -orient horizontal -showvalue true \
	    -variable ::window::data($name) -from $from -to $to \
	    -command [list ::window::adjust $w $f $name]
	pack $w.$name.scale -fill x -expand true
	return $w.$name
    }
    
    proc myoptionmenu {w f name values} {
	labelframe $w.$name -text [string totitle $name]
	set m [tk_optionMenu $w.$name.options ::window::data($name) {*}$values]
	$w.$name.options configure -width [max-width $values]
	foreach v $values {
	    $m entryconfigure $v -command [list ::window::adjust $w $f $name $v]
	}
	pack $w.$name.options -fill x -expand true
	return $w.$name
    }
    
    proc controls {w f} {

	if {[winfo exists $w]} { destroy $w }

	# controls
	toplevel $w
	
	# choices
	pack [myoptionmenu $w $f instrument [::instrument::get-instruments]] -side top -fill x -expand true
	pack [myoptionmenu $w $f tuning [::instrument::get-tunings $::window::data(instdict)]] -side top -fill x -expand true
	pack [myoptionmenu $w $f tonic [::midi::get-keys]] -side top -fill x -expand true
	pack [myoptionmenu $w $f mode [::midi::get-modes]] -side top -fill x -expand true
	pack [myscale $w $f nut -24 24] -side top -fill x -expand true
	pack [myscale $w $f frets 1 36] -side top -fill x -expand true
	pack [myoptionmenu $w $f sound [::sound::list-sounds]] -side top -fill x -expand true

	# control buttons
	pack [button $w.done -text Dismiss -command [list destroy $w]] -side top -fill x -expand true
	pack [button $w.quit -text Quit -command {destroy .}] -side top -fill x -expand true
	pack [button $w.panic -text Panic -foreground red -command {sound::stop}] -side top -fill x -expand true
    }

    proc control-rebuild-tuning {w f} {
	if {[winfo exists $w] && [winfo exists $w.tuning]} {
	    destroy $w.tuning
	    pack [myoptionmenu $w $f tuning [::instrument::get-tunings $::window::data(instdict)]] -side top -fill x -expand true -after $w.instrument
	}
    }
    
    proc main {args} {

	# canvas fretboard
	pack [canvas .fretboard] -side top -fill both -expand true
	.fretboard configure -width $::params::params(width) -height $::params::params(height) -bg black \
	    -bd 0 -highlightthickness 0 -insertborderwidth 0 -selectborderwidth 0
	
	# bindings for window configure and control button
	bind .fretboard <Configure> {::window::redraw .fretboard}
	bind .fretboard <Button-3> {::window::controls .zither .fretboard}

	# touch handler
	touch::init .fretboard

	# set default values, first time
	array set ::window::data [array get ::params::defaults]
	
	# set default values, second time
	::window::adjust-all .zither .fretboard [array get ::window::data]
	
	if {$::params::params(touch)} {
	    bind .fretboard <<TouchBegin>> {::window::note + %d %x %y}
	    bind .fretboard <<TouchUpdate>> {::window::note . %d %x %y}
	    bind .fretboard <<TouchEnd>> {::window::note - %d %x %y}
	}
	if {$::params::params(mouse)} {
	    bind .fretboard <ButtonPress-1> {::window::note + f %x %y}
	    bind .fretboard <B1-Motion> {::window::note . f %x %y}
	    bind .fretboard <ButtonRelease-1> {::window::note - f %x %y}
	}

	::window::adjust-all .zither .fretboard $args

	if {$::params::params(fullscreen)} {
	    after 1 {
		wm attributes . -fullscreen $::params::params(fullscreen)
		# puts [winfo geometry .]
	    }
	}
    }
}
