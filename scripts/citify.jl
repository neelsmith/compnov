# Map ebibles project's abbrevations to CITE2 work names:
books = Dict([
    ("GEN", "genesis"),
    ("EXO", "exodus"),
    ("LEV", "leviticus"),
    ("NUM", "numbers"),
    ("DEU", "deuteronomy"),
    ("JOS", "joshua"),
    ("JDG", "judges"),
    ("1SA", "samuel1"),
    ("2SA", "samuel2"),
    ("1KI", "kings1"),
    ("2KI", "kings2"),
    ("ISA", "isaiah"),
    ("JER", "jeremiah"),
    ("EZE", "ezekiel"),

    ("HOS", "hosea"),
    ("JOE", "joel"),
    ("AMO", "amos"),
    ("OBA", "obadiah"),
    ("JON", "jonah"),
    ("MIC", "micah"),
    ("NAH", "nahum"),
    ("HAB", "habakkuk"),
    ("ZEP", "zephaniah"),
    ("HAG", "haggai"),
    ("ZEC", "zechariah"),
    ("MAL", "malachi"),

    ("PSA", "psalms"),
    ("PRO", "proverbs"),
    ("JOB", "job"),
    ("SOL", "songs"),
    ("RUT", "ruth"),
    ("LAM", "lamentations"),
    ("ECC", "ecclesiastes"),
    ("EST", "esther"),
    ("DAN", "daniel"),
    ("EZR", "ezra"),
    ("NEH", "nehemiah"),
    ("1CH", "chronicles2"),
    ("2CH", "chronicles2"),

    ("TOB", "tobit"),
    ("JDT", "judith"),
    ("ESG","esther2"),
    ("WIS","wisdom"),
    ("SIR","sirach"),
    ("BAR","baruch"),
    ("EPJ","epistlejeremy"),
    ("SUS","susanna"),
    ("BEL","bel"),
    ("1MA","maccabees1"),
    ("2MA","maccabees2"),
    ("1ES","esdras1"),
    ("PRM","manasseh"),
    ("3MA","maccabees3"),
    ("4MA","maccabees4"),
    ("DNG","daniel2")
    
    ]
)

version = Dict([
    ("grcbrent_vpl.txt", "septuagint"),
    ("hbo_vpl.txt", "masoretic" ),
    ("latVUC-OT_vpl.txt", "vulgate")
])
urnbase = "urn:cts:compnov:tanach."

src = joinpath(pwd(), "src")
corpuslines = []
for f in filter(fname -> endswith(fname, ".txt"), readdir(src))
    
    srclines = readlines(joinpath(src,f))
    map(srclines) do ln
        pieces = split(ln, r"[ ]+")
        if length(pieces) < 3
            @warn("Couldn't parse $(ln)")
        else
            push!(corpuslines, string(urnbase, books[pieces[1]], ".", version[f], ":", pieces[2], "|", join(pieces[3:end], " ")))
        end
    end
    println("Read $(f).")
end

open(joinpath(pwd(), "corpus", "compnov.cex"), "w") do io
    write(io, "#!ctsdata\n" * join(corpuslines, "\n"))
end











