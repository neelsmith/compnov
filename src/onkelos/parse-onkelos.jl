repo = pwd() 
genesis_src = joinpath(repo, "src", "onkelos", "genesis-merged.txt")

genesis_src
srclines =  filter(readlines(genesis_src)) do ln
    !isempty(ln)
end


currchap = ""

urnbase = "urn:cts:compnov:tanach.genesis.onkelos:"
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
        #tidier = ln
        push!(reff, string(urnbase, ref, "|", tidy2))
    end   
end


open("onkelos.cex", "w") do io
    write(io, "#!ctsbase\n" * join(reff, "\n"))
end


