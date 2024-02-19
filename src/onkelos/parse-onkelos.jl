repo = pwd() 

"""Read file from Sefaria Project and format as CTS corpus in CEX format."""
function formattext(f, book)
    srclines =  filter(readlines(f)) do ln
        !isempty(ln)
    end

    urnbase = "urn:cts:compnov:tanach.$(book).onkelos:"
    reff = []
    chap = ""
    verse = 0
    for ln in srclines
        if startswith(ln, "Chapter ")
            chapref = replace(ln, "Chapter " => "")     
            chap = chapref
            verse = 0
            
        else
            verse = verse + 1
            ref = string(chap, ".", verse)
            tidy1 = replace(ln, r"<[/]?b>" => "")
            tidy2 = replace(tidy1, r"<[/]?small>" => "")
            push!(reff, string(urnbase, ref, "|", tidy2))
        end   
    end
    join(reff, "\n")
end


books = []
for book in ["genesis", "exodus", "leviticus", "numbers", "deuteronomy"]
    srcfile = joinpath(repo, "src", "onkelos", "$(book)-merged.txt")
    formatted = formattext(srcfile, book)
    push!(books, formatted)
end

open("onkelos.cex", "w") do io
    write(io, join(books, "\n"))
end







