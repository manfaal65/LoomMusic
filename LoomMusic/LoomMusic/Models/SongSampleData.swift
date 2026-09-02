//
//  SongSampleData.swift
//  LoomMusic
//

import SwiftUI

extension Song {
    // Dummy sample songs removed — real song data will be wired in separately.
    // The original 10 sample entries are kept below, disabled, in case they're
    // still useful as reference/fallback data later.
    static let sample: [Song] = []

    #if false
    static let sampleArchive: [Song] = [
        Song(
            title: "Glass Horizon",
            artist: "Nova Reyes",
            year: "2024",
            duration: "3:42",
            genre: "Synth-Pop",
            artColors: [Color(red: 0.35, green: 0.62, blue: 0.82), Color(red: 0.10, green: 0.24, blue: 0.40)],
            lyrics: [
                "Every skyline learns to bend\nwhen the static fades to grey\nI keep tracing where we've been\non a map that blew away",
                "You were light through frosted glass\na color I could never name\nnow the evening moves so fast\nbut I still call out your name"
            ],
            info: SongInfo(album: "Afterlight", year: "2024", genre: "Synth-Pop", duration: "3:42", writer: "N. Reyes / D. Cole", producer: "Priya Nakamura", label: "Afterlight Records")
        ),
        Song(
            title: "Midnight Static",
            artist: "The Amber Hours",
            year: "2023",
            duration: "4:05",
            genre: "Dream Pop",
            artColors: [Color(red: 0.62, green: 0.24, blue: 0.44), Color(red: 0.22, green: 0.08, blue: 0.18)],
            lyrics: [
                "Radio hum through an empty hall\nvoices caught between the walls\nI hear you calling faint and far\nlost behind the midnight static",
                "Hold the dial, don't let it turn\nsome frequencies we never learn\nstill I search the empty band\nfor the sound of your hand"
            ],
            info: SongInfo(album: "Amber Hours", year: "2023", genre: "Dream Pop", duration: "4:05", writer: "R. Falk", producer: "Owen Marsh", label: "Amber Hours Records")
        ),
        Song(
            title: "Paper Boats",
            artist: "Cass Ellery",
            year: "2022",
            duration: "3:18",
            genre: "Indie Folk",
            artColors: [Color(red: 0.20, green: 0.24, blue: 0.42), Color(red: 0.06, green: 0.07, blue: 0.16)],
            lyrics: [
                "We folded paper boats and let them go\ndown the gutter after summer rain\nwatched them spin and dip and lean\ninto the drain",
                "Somewhere they're still sailing on\npast every yard we used to know\nI think of you when the weather turns\nand the paper boats float"
            ],
            info: SongInfo(album: "Little Harbors", year: "2022", genre: "Indie Folk", duration: "3:18", writer: "C. Ellery", producer: "C. Ellery", label: "Independent")
        ),
        Song(
            title: "Neon Rain",
            artist: "Marlow & the Static",
            year: "2024",
            duration: "3:56",
            genre: "Electropop",
            artColors: [Color(red: 0.78, green: 0.52, blue: 0.20), Color(red: 0.30, green: 0.18, blue: 0.05)],
            lyrics: [
                "City lights are bleeding through the glass\nneon rain on the overpass\nI can hear the traffic sing\nyour name in everything",
                "Run with me through the flooded street\nchase the colors at our feet\nnothing's ever felt this loud\nstanding in the neon crowd"
            ],
            info: SongInfo(album: "Static & Light", year: "2024", genre: "Electropop", duration: "3:56", writer: "J. Marlow / K. Reyes", producer: "Sam Idris", label: "Static & Light Records")
        ),
        Song(
            title: "Slow Bloom",
            artist: "Iris Vance",
            year: "2021",
            duration: "4:22",
            genre: "Alt R&B",
            artColors: [Color(red: 0.16, green: 0.46, blue: 0.34), Color(red: 0.05, green: 0.15, blue: 0.11)],
            lyrics: [
                "Give it time, let it slow bloom\ndon't rush the light into the room\nsome things open on their own\nlong after we've let go",
                "Petals on a windowsill\nwaiting for a warmer chill\nI'm learning how to let it grow\nslow, slow, slow bloom"
            ],
            info: SongInfo(album: "Slow Bloom", year: "2021", genre: "Alt R&B", duration: "4:22", writer: "I. Vance", producer: "Terrence Boyd", label: "Vance House")
        ),
        Song(
            title: "Concrete Halo",
            artist: "7th Avenue",
            year: "2023",
            duration: "3:31",
            genre: "Indie Rock",
            artColors: [Color(red: 0.70, green: 0.20, blue: 0.24), Color(red: 0.24, green: 0.06, blue: 0.08)],
            lyrics: [
                "Streetlight halo on the concrete ground\nfootsteps echo with no sound\nwe were kings of the parking lot\nunder a halo we forgot",
                "Nothing gold survives the town\nbut we kept our crowns around\nstill I see it when I'm home\nthat concrete halo glow"
            ],
            info: SongInfo(album: "7th Avenue", year: "2023", genre: "Indie Rock", duration: "3:31", writer: "M. Ortiz / T. Reign", producer: "M. Ortiz", label: "Independent")
        ),
        Song(
            title: "Copper Sky",
            artist: "Wilder Season",
            year: "2022",
            duration: "3:47",
            genre: "Indie Pop",
            artColors: [Color(red: 0.42, green: 0.30, blue: 0.66), Color(red: 0.14, green: 0.09, blue: 0.24)],
            lyrics: [
                "Copper sky over the interstate\nwe left before the hour got late\nradio static, open door\nchasing something we're not sure of",
                "Somewhere past the county line\neverything felt right on time\nwe were young under a copper sky\nnever asking why"
            ],
            info: SongInfo(album: "Wilder Season", year: "2022", genre: "Indie Pop", duration: "3:47", writer: "A. Wilder", producer: "Nadia Bloom", label: "Season Records")
        ),
        Song(
            title: "Low Tide",
            artist: "Sable & June",
            year: "2020",
            duration: "4:11",
            genre: "Chillwave",
            artColors: [Color(red: 0.62, green: 0.56, blue: 0.20), Color(red: 0.20, green: 0.18, blue: 0.06)],
            lyrics: [
                "Low tide pulls the noise away\nleaves us with the quiet grey\nfootprints fading in the sand\nlike everything we planned",
                "We'll wait here till the water turns\nwatch the evening slowly burn\nnothing's lost that comes back twice\nlike the low tide"
            ],
            info: SongInfo(album: "Coastline", year: "2020", genre: "Chillwave", duration: "4:11", writer: "S. Marsh / J. Cole", producer: "S. Marsh", label: "Coastline Tapes")
        ),
        Song(
            title: "Static Bloom",
            artist: "Kilo Moth",
            year: "2024",
            duration: "3:28",
            genre: "Shoegaze",
            artColors: [Color(red: 0.36, green: 0.38, blue: 0.42), Color(red: 0.10, green: 0.11, blue: 0.13)],
            lyrics: [
                "Feedback blooming through the wall\nsofter now than I recall\nevery chord a little bruise\nevery bruise a thing I choose",
                "Let the static bloom and fade\nsomewhere in the noise we made\nI can still hear it in the room\nthat quiet static bloom"
            ],
            info: SongInfo(album: "Kilo Moth", year: "2024", genre: "Shoegaze", duration: "3:28", writer: "Kilo Moth", producer: "Dana Frost", label: "Moth Recordings")
        ),
        Song(
            title: "Afterglow",
            artist: "The Quiet Parade",
            year: "2021",
            duration: "3:53",
            genre: "Synth-Pop",
            artColors: [Color(red: 0.72, green: 0.28, blue: 0.46), Color(red: 0.26, green: 0.09, blue: 0.17)],
            lyrics: [
                "Streetlamps hum an afterglow\nlong after everyone's gone home\nI'm still standing where you left\nwearing out the afterglow",
                "Maybe colors fade like this\neasy as a goodnight kiss\nbut I'm holding on so slow\nto this afterglow"
            ],
            info: SongInfo(album: "The Quiet Parade", year: "2021", genre: "Synth-Pop", duration: "3:53", writer: "L. Voss", producer: "L. Voss", label: "Quiet Parade Records")
        )
    ]
    #endif
}
