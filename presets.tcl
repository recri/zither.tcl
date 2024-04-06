package provide ::presets 1.0


namespace eval ::presets {
    set flat {♭}
    set sharp {♯}
    set dash {–}

    set presets [dict create {*}{
	dulcimer-3            { strings 3 root D4 tuning {0 -5 -7}}
	dulcimer-3-trad-1     { strings 3 root G3 tuning {0 0 -7}}
	dulcimer-3-trad-2     { strings 3 root C4 tuning {0 -5 -7}}
	dulcimer-3-trad-3     { strings 3 root C4 tuning {0 -7 -5}}
	dulcimer-3-mod-1      { strings 3 root A3 tuning {0 0 -7}}
	dulcimer-3-mod-2      { strings 3 root D4 tuning {0 -5 -7}}
	dulcimer-3-mod-3      { strings 3 root D4 tuning {0 -7 -5}}

	dulcimer-4            { strings 4 root D4 tuning {0 0 -5 -7}}
	bass-guitar-4         { strings 4 root E1 tuning {0  5 5 5}}
	ukulele-4             { strings 4 root G4 tuning {0 -7 4 5}}
	ukulele-pocket        { strings 4 root D5 tuning {0 -7 4 5}}
	ukulele-pocket-alt    { strings 4 root C5 tuning {0 -7 4 5}}
	ukulele-soprano       { strings 4 root G4 tuning {0 -7 4 5}}
	ukulele-soprano-alt-1 { strings 4 root A4 tuning {0 -7 4 5}}
	ukulele-soprano-alt-2 { strings 4 root G3 tuning {0  5 4 5}}
	ukulele-concert       { strings 4 root G4 tuning {0 -7 4 5}}
	ukulele-concert-alt   { strings 4 root G3 tuning {0  5 4 5}}
	ukulele-tenor         { strings 4 root G4 tuning {0 -7 4 5}}
	ukulele-tenor-alt-1   { strings 4 root D4 tuning {0 -7 4 5}}
	ukulele-tenor-alt-2   { strings 3 root A3 tuning {0  5 4 5}}
	ukulele-tenor-alt-3   { strings 4 root D3 tuning {0  5 4 5}}
	ukulele-baritone      { strings 4 root D3 tuning {0  5 4 5}}
	ukulele-baritone-alt  { strings 4 root C3 tuning {0  7 4 5}}
	ukulele-bass          { strings 4 root E1 tuning {0  5 5 5}}
	ukulele-bass-alt      { strings 4 root D1 tuning {0  7 5 5}}
	banjo-4               { strings 4 root C3 tuning {0  7 7 7}}
	banjo-4-std           { strings 4 root C3 tuning {0  7 7 7}}
	violin-4              { strings 4 root G3 tuning {0  7 7 7}}
	violin-std            { strings 4 root G3 tuning {0  7 7 7}}
	violin-cajun          { strings 4 root F3 tuning {0  7 7 7}}
	violin-open-G         { strings 4 root G3 tuning {0  7 5 4}}
	violin-sawmill        { strings 4 root G3 tuning {0  7 5 7}}
	violin-gee-dad        { strings 4 root G3 tuning {0  7 7 5}}
	violin-dead-man       { strings 4 root D4 tuning {0  0 7 5}}
	violin-high-bass      { strings 4 root A3 tuning {0  5 7 7}}
	violin-cross-tuning   { strings 4 root A3 tuning {0  7 5 7}}
	violin-calico         { strings 4 root A3 tuning {0  7 5 4}}
	violin-old-sledge     { strings 4 root A3 tuning {0  7 5 5}}
	violin-glory-in-the-meeting-house { strings 4 root E3 tuning {0 10 7 7}}
	violin-get-up-in-the-cool { strings 4 root E4 tuning {0 0 5 7}}

	bass-guitar-5-low     { strings 5 root B0 tuning {0 5 5 5 5}}
	bass-guitar-5-high    { strings 5 root E1 tuning {0 5 5 5 5}}
	bass-5                { strings 5 root B0 tuning {0 5 5 5 5}}
	banjo-5               { strings 5 root G4 tuning {0 -19 7 4 3}}
	banjo-5-std           { strings 5 root G4 tuning {0 -19 7 4 3}}
	banjo-5-open-G        { strings 5 root G4 tuning {0 -17 5 4 3}}
	banjo-5-open-G-alt    { strings 5 root G4 tuning {0 -19 7 4 3}}
	banjo-5-double-C      { strings 5 root G4 tuning {0 -19 7 5 2}}
	banjo-5-sawmill       { strings 5 root G4 tuning {0 -17 5 5 2}}
	banjo-5-open-D        { strings 5 root F#4 tuning {0 -16 4 3 5}}
	banjo-5-double-D      { strings 5 root A4 tuning {0 -19 7 5 2}}
	banjo-5-open-A        { strings 5 root A4 tuning {0 -17 5 4 3}}
	bass-guitar-6-low     { strings 6 root B0 tuning {0 5 5 5 5 5}}
	bass-guitar-6-high    { strings 6 root E1 tuning {0 5 5 5 5 5}}
	guitar-6              { strings 6 root E2 tuning {0 5 5 5 4 5}}
	fourths-6             { strings 6 root E2 tuning {0 5 5 5 5 5}}
	thirds-6              { strings 6 root E2 tuning {0 4 4 4 4 4}}
	fifths-6              { strings 6 root C2 tuning {0 7 7 7 7 7}}

	guitar-7              { strings 7 root D2 tuning {0 5 4 3 5 4 3}}
	mandolin-8            { strings 8 root G3 tuning {0 0 7 0 7 0 7 0}}
	guitar-12             { strings 12 root E1 tuning {0 12 -7 12 -7 12 -7 12 4 0 5 0}}
	lyre-7 { strings 7 root D4 tuning {0 2 3 2 2 3 2}}
	lyre-16 { strings 16 root G3 tuning {0 2 2 1 2 2 1 2 2 2 1 2 2 1 2 2}}
	zither-munich { strings 42 root A4 tuning {0 0 -7 -7 -7 15 -5 7 -5 -5 7 -5 7 -5 -5 7 -5 -5 -5 7 -5 -5 7 -5 7 -5 -5 7 -5 -3 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1}}
	zither-viennese { strings 38 root A4 tuning {0 -7 5 -12 -7 20 -5 -5 7 -5 7 -5 -5 7 -5 7 -5 -5 -17 7 -5 7 -5 -5 7 -5 7 -5 -5 7 -8 -1 -1 -1 -1 -1 -1 -1}}

	stick-8-1 { strings 8 root B0 tuning {0 5 5 5 5 5 5 5}}
	stick-8-2 { strings 8 root B0 tuning {0 5 5 5 5 5 4 5}}
	stick-8-3 { strings 8 root B0 tuning {0 5 5 5 5 4 5 5}}
	stick-8-4 { strings 8 root A2 tuning {0 -7 -7 -7 16 5 5 5}}
	stick-8-5 { strings 8 root A2 tuning {0 -7 -7 -7 18 5 5 5}}

	stick-10-1 { strings 10 root E3 tuning {0 -7 -7 -7 -7 16 5 5 5 5}}
	stick-10-2 { strings 10 root E3 tuning {0 -7 -7 -7 -7 18 5 5 5 5}}
	stick-10-3 { strings 10 root E3 tuning {0 -7 -7 -7 -7 13 5 5 5 5}}
	stick-10-4 { strings 10 root E3 tuning {0 -7 -7 -7 -7 11 5 5 5 5}}
	stick-10-5 { strings 10 root D3 tuning {0 -7 -7 -7 -7 16 5 5 5 5}}
	stick-10-6 { strings 10 root F#3 tuning {0 -7 -7 -7 -7 4 17 5 5 5}}
	stick-10-7 { strings 10 root F#3 tuning {0 -7 -7 -7 -7 11 5 5 5 5}}
	stick-10-8 { strings 10 root D#3 tuning {0 -7 -7 -7 -7 17 5 5 5 5}}

	stick-12-1 { strings 12 root B3 tuning {0 -7 -7 -7 -7 -7 11 5 5 5 5 5}}
	stick-12-2 { strings 12 root B3 tuning {0 -7 -7 -7 -7 -7 13 5 5 5 5 5}}
	stick-12-3 { strings 12 root A3 tuning {0 -5 -7 -7 -7 -7 11 5 5 5 5 5}}
	stick-12-4 { strings 12 root A3 tuning {0 -5 -7 -7 -7 -7 13 5 5 5 5 5}}
	stick-12-5 { strings 12 root A3 tuning {0 -7 -7 -7 -7 -7 11 5 5 5 5 5}}
	stick-12-6 { strings 12 root C#4 tuning {0 -7 -7 -7 -7 -7 11 5 5 5 5 5}}
	stick-12-7 { strings 12 root A#3 tuning {0 -7 -7 -7 -7 -7 5 5 5 5 5 5}}
    }]

    set simple {
	dulcimer-3
	dulcimer-4
	bass-guitar-4
	ukulele-4
	banjo-4
	violin-4
	bass-guitar-5-low
	bass-guitar-5-high
	banjo-5
	bass-guitar-6-low
	bass-guitar-6-high
	guitar-6
	guitar-7
	mandolin-8
	stick-8-1
	stick-10-1
	guitar-12
	stick-12-1
    }
}

proc ::presets::allkeys {} { dict keys $::presets::presets }
proc ::presets::keys {} { set ::presets::simple }
proc ::presets::value {name} { dict get $::presets::presets $name }
