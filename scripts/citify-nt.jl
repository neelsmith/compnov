# Map ebibles project's abbrevations to CITE2 work names:
books = Dict([
    ("MAT", "matthew"),
    ("MAR", "mark"),
    ("LUK", "mark"),
    ("JOH", "mark"),
    ("ACT", "acts"),
    ("ROM", "rom"),
    ("1CO", "1corinthians"),
    ("2CO", "2corinthians"),
    ("GAL", "galatians"),
    ("EPH", "ephesians"),
    ("PHI", "philippians"),
    ("COL", "colossians"),
    ("EPH", "ephesians"),
    ("1TH", "1thessalonians"),
    ("2TH", "2thessalonians"),
    ("1TI", "1timothy"),
    ("2TI", "2timothy"),
    ("TIT", "titus"),
    ("PHM", "philemon"),
    ("HEB", "hebrews"),
    ("JAM", "james"),
    ("1PE", "1peter"),
    ("2PE", "2peter"),
    ("1JO", "1john"),
    ("2JO", "2john"),
    ("3JO", "3john"),
    ("JUD", "jude"),
    ("REV", "revelations")
    
    ]
)

version = Dict([
    ("grc-tisch_vpl.txt", "greeknt"),
    
    ("latVUC-NT_vpl.txt", "vulgate")
])
urnbase = "urn:cts:compnov:bible."

src = joinpath(pwd(), "src", "nt")
corpuslines = []
for f in filter(fname -> endswith(fname, ".txt"), readdir(src))
    
    srclines = readlines(joinpath(src,f))
    map(srclines) do ln
        pieces = split(ln, r"[ ]+")
        if length(pieces) < 3
            @warn("Couldn't parse $(ln)")
        else
            push!(corpuslines, string(urnbase, books[pieces[1]], ".", version[f], ":", replace(pieces[2], ":" => "."), "|", join(pieces[3:end], " ")))
        end
    end
    println("Read $(f).")
end

open(joinpath(pwd(), "corpus", "compnov_nt.cex"), "w") do io
    write(io, "#!ctsdata\n" * join(corpuslines, "\n"))
end











