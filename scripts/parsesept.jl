using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using StatsBase, OrderedCollections

parserfile = "/Users/nsmith/Dropbox/_parsers/attic-2024-02-14-T0617.csv"
parser = dfParser(parserfile)


# Make sure thestwo directories `repo` and `kroot` have the right
# values for the root of the compnov repository and the root of the 
# Kanones.jl repository:
repo = pwd()
desk = repo |> dirname |> dirname 
kroot = joinpath(desk, "greek-work", "Kanones.jl")


textsrc = joinpath(repo, "corpus", "compnov.cex")

corpus = fromcex(textsrc, CitableTextCorpus, FileReader)
sept = filter(corpus.passages) do psg
    versionid(psg.urn) == "septuagint"
end |> CitableTextCorpus
tkns = tokenize(sept, literaryGreek())

lex = filter(tkns) do t
    t.tokentype isa LexicalToken
end

wordforms = map(x -> Kanones.knormal(x.passage.text), lex)
wordformfreqs = countmap(wordforms) |> OrderedDict

wordformssorted = sort(wordformfreqs, byvalue = true, rev = true)

vocab = keys(wordformssorted) |> collect

open("sept-vocab.txt", "w") do io
    write(io, join(vocab,"\n"))
end


parses = parsewordlist(vocab, parser)


fails = []
for (wd, alist) in zip(vocab, parses)
    if isempty(alist)
        push!(fails, wd)
    end
end


failfreqs = map(fails) do wd
    string(wd, " ", wordformfreqs[wd])
end

open("failed-counts.txt", "w") do  io
    write(io, join(failfreqs, "\n"))
end