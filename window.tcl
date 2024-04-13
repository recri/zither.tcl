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
    variable geom
    
    proc get-instrument {} { ::instrument::get-instrument $::window::data(instrument) }

    proc get-tunings {} { ::instrument::get-tunings $::window::data(instrument) }
    
    proc get-tuning {} { ::instrument::get-tuning $::window::data(instrument) $::window::data(tuning) }

    proc get-expanded-tuning {} { ::instrument::expand-tuning [get-tuning] }

    proc expand-tuning {} {
	if { ! [info exists ::window::data(tuning)] || $::window::data(tuning) ni [get-tunings]} {
	    set ::window::data(tuning) [lindex [get-tunings] 0] 
	}
	get-expanded-tuning
    }

    proc adjust {w f which {value {}} {redraw 1}} {
	
	# puts "adjust $w $f $which $value $redraw -> $::window::data($which)"
	if {$value ne {}} { set ::window::data($which) $value }
	
	# the fretboard is a rectangle of "buttons" frets wide and strings high
	# which has a tuning specified by the root note in the lower left corner
	switch $which {
	    instrument {	# the base instrument
		# puts [expand-tuning]
		::window::adjust-all $w $f [expand-tuning] $redraw
		controls $w $f
	    }
	    courses {	# the number of string courses
	    }
	    multiplicity { # the number of strings in each course
	    }
	    frets {	# the number of frets on the fretboard
	    }
	    strings {	# the number of strings on the fretboard
	    }
	    root {	# the note of the open string at bottom/closest to player
	    }
	    nut {	# nut shifts the whole fretboard by semitones
	    }
	    stringnotes {	# the midi note for each string
	    }
	    tuning {	# the notes the strings are tuned to from closest to furthest
		# puts [expand-tuning]
		::window::adjust-all $w $f [expand-tuning] $redraw
	    }
	    tonic {	# the tonic is the note which is the root of the scale
	    }
	    mode {	# the mode determines which scale is labelled from the root
	    }
	    sound {
		::sound::select $::window::data(sound)
	    }
	    default {
		error "no case for $which in adjust"
	    }
	}
	if {$redraw} { redraw $f }
    }

    proc adjust-all {w f keyvals {redraw 1}} {
	# puts "adjust-all $w $f {$keyvals}"
	if {[llength $keyvals] > 0} {
	    if {[llength $keyvals] > 2} {
		foreach {key value} [lrange $keyvals 0 end-2] { ::window::adjust $w $f $key $value 0 }
	    }
	    ::window::adjust $w $f {*}[lrange $keyvals end-1 end] $redraw
	}
    }
    
    proc make-button {f} {
	# first the geometry of frets and strings
	set ::window::geom(cwid) [winfo width $f]
	set ::window::geom(chgt) [winfo height $f]
	set ::window::geom(fper) [expr {$::window::geom(chgt)/double($::window::data(frets))}]
	set ::window::geom(sper) [expr {$::window::geom(cwid)/double($::window::data(courses))}]
	set ::window::geom(xper) $::window::geom(sper)
	set ::window::geom(yper) $::window::geom(fper)

	# now the geometry of the button
	set in 4
	set x0 $in
	set y0 $in
	set xm [expr {$::window::geom(xper)/2.0}]
	set ym [expr {$::window::geom(yper)/2.0}]
	set xc [expr {$::window::geom(xper)-$in}]
	set yc [expr {$::window::geom(yper)-$in}]
		
	# now build the button coordinates
	set ::window::geom(button) [list $x0 $y0 $x0 $ym $x0 $yc $xm $yc $xc $yc $xc $ym $xc $y0 $xm $y0]

	# now the font for the button label
	if {{MyButtonFont} ni [font names]} {
	    font create MyButtonFont {*}[font configure TkHeadingFont] -size 16
	}
    }

    proc draw-button {f course fret text} {
	# get the coordinates
	foreach {x y} [fret-to-window $course $fret] break;

	# locate the button
	set xc [expr {$x+$::window::geom(xper)}]
	set yc [expr {$y+$::window::geom(yper)}]

	# draw the button
	set p [$f create polygon $::window::geom(button) -outline white -fill {} -smooth true]

	# move it into position
	$f move $p $x $y

	# label button
	set l [$f create text [expr {$x+0.5*$::window::geom(xper)}] [expr {$y+0.5*$::window::geom(yper)}] -text $text -anchor c -fill white -font MyButtonFont]
	
	# return item identifier
	list $p $l
    }
    
    proc redraw {f} {
	set inst [get-instrument]
	set tonicnote [::midi::name-to-note $::window::data(tonic)]
	set scalenotes [lmap n [::midi::get-mode $::window::data(mode)] {expr {($tonicnote+$n)%12}}]
	make-button $f
	
	$f delete all

	# notes will become a list of lists of lists
	# [lindex [lindex $notes $course] $fret] will return a list of notes to play
	set notes {}

	for {set course 0} {$course < $::window::data(courses)} {incr course} {
	    set i1 [expr {$course*$::window::data(multiplicity)}]
	    set i2 [expr {($course+1)*$::window::data(multiplicity)-1}]
	    set stringnote [lmap n [lrange $::window::data(stringnotes) $i1 $i2] {expr {$n+$::window::data(nut)}}]
	    set stringnotes {}
	    for {set fret 0} {$fret < $::window::data(frets)} {incr fret} {
		set fretnote [lmap n $stringnote {expr {$n+$fret}}]
		lappend stringnotes $fretnote
		set fretnote [lindex $fretnote 0]
		foreach {p l} [draw-button $f $course $fret [::midi::note-to-name $fretnote $::window::data(tonic)]] break

		if {[lsearch -exact -integer $scalenotes [expr {$fretnote % 12}]] >= 0} {
		    if {$tonicnote == ($fretnote % 12)} {
			# highlight the tonic
			$f itemconfigure $p -width 5 -outline white
		    } else {
			# emphasize the scale
			$f itemconfigure $p -width 2 -outline white
		    }
		} else {
		    # deemphasize the accidentals
		    $f itemconfigure $l -fill darkgrey
		    $f itemconfigure $p -width 1 -outline grey20
		}
	    }
	    lappend notes $stringnotes
	}
	set ::window::geom(notes) $notes
    }


    ##
    ## coordinate transformation
    ##
    
    # translate touch coordinates into the window system coordinates
    # x or wayland would do this for us, but Tk doesn't handle touch
    proc touch-to-window {x y} {
	return [list $y [expr {max(0,$::window::geom(chgt)-$x-1)}]]
    }	

    # translate window coordinates, x and y increasing from upper right corner
    # into string and fret
    # well, not exactly.  Translate touch input coordinates, which didn't rotate
    # with the screen when we put the touchscreen into portrait mode.
    proc touch-to-fret {x y} {
	foreach {x y} [::window::touch-to-window $x $y] break
	set sreal [expr {$x/$::window::geom(sper)}]
	set freal [expr {$y/$::window::geom(fper)}]
	set s [expr {max(0,min($::window::data(strings), int($sreal)))}]
	set f [expr {max(0,min($::window::data(frets), int($freal)))}]
	set sfrac [expr {$sreal-$s}]
	set ffrac [expr {$freal-$f}]
	list $s $f $sfrac $ffrac
    }

    # translate string and fret coordinates into window coordinates
    # in this case, they are window coordinates, and this should be
    # orientation independent
    proc fret-to-window {string fret} {
	set y [expr {$fret*$::window::geom(fper)}]
	set x [expr {$string*$::window::geom(sper)}]
	list $x $y
    }
    
    ##
    ## play the note
    ##
    proc note {action id x y} {
	foreach {string fret stringfrac fretfrac} [touch-to-fret $x $y] break
	# puts "note $action $id $x $y $string $fret"
	set i 0
	foreach note [lindex [lindex $::window::geom(notes) $string] $fret] {
	    sound::note $action $id.[incr i] [midi::mtof $note]
	}
    }

    ##
    ## control panel
    ##
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
    
    proc myoptionmenuselect {w f name} {
	# puts "myoptionmenuselect $w $f $name [$w.$name.options get] $::window::data($name)"
	$w.$name.options selection clear
	::window::adjust $w $f $name
    }

    proc myoptionmenu {w f name values} {
	labelframe $w.$name -text [string totitle $name]
	pack [ttk::combobox $w.$name.options -textvariable ::window::data($name) -values $values -state readonly -width [max-width $values]] -fill x -expand true
	bind $w.$name.options <<ComboboxSelected>> [list ::window::myoptionmenuselect $w $f $name]
	return $w.$name
    }
    
    proc controls {w f} {

	if {[winfo exists $w]} {
	    wm withdraw $w
	    $w.tuning.options configure -values [get-tunings]
	    wm deiconify $w
	} else {

	    # controls
	    toplevel $w
	
	    # choices
	    pack [myoptionmenu $w $f instrument [lsort [::instrument::get-instruments]]] -side top -fill x -expand true
	    pack [myoptionmenu $w $f tuning [get-tunings]] -side top -fill x -expand true
	    pack [myoptionmenu $w $f tonic [::midi::get-keys]] -side top -fill x -expand true
	    pack [myoptionmenu $w $f mode [::midi::get-modes]] -side top -fill x -expand true
	    pack [myscale $w $f nut -24 24] -side top -fill x -expand true
	    pack [myscale $w $f frets 1 36] -side top -fill x -expand true
	    pack [myoptionmenu $w $f sound [lsort [::sound::list-sounds]]] -side top -fill x -expand true

	    # control buttons
	    pack [button $w.done -text Dismiss -command [list wm withdraw $w]] -side top -fill x -expand true
	    pack [button $w.quit -text Quit -command {destroy .}] -side top -fill x -expand true
	    pack [button $w.panic -text Panic -foreground red -command {sound::stop}] -side top -fill x -expand true
	}
    }

    proc main {args} {

	# set default values, first time
	array set ::window::data [array get ::params::defaults]

	# set values passed as arguments
	array set ::window::data  $args
	
	# expand instrument
	array set ::window::data [expand-tuning]

	# canvas fretboard
	pack [canvas .fretboard] -side top -fill both -expand true
	.fretboard configure -width $::params::params(width) -height $::params::params(height) -bg black \
	    -bd 0 -highlightthickness 0 -insertborderwidth 0 -selectborderwidth 0
	
	# bindings for window configure and control button
	bind .fretboard <Configure> {::window::redraw .fretboard}
	bind .fretboard <Button-3> {::window::controls .zither .fretboard}

	# touch handler
	touch::init .fretboard

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

	if {$::params::params(fullscreen)} {
	    after 1 {
		wm attributes . -fullscreen $::params::params(fullscreen)
		# puts [winfo geometry .]
	    }
	}
    }
}
