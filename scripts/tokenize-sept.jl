# Tokenize the corpora and get token frequencies.
repo = pwd() 

using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek, BiblicalHebrew
using Kanones
using StatsBase, OrderedCollections

srcfile = joinpath(repo,"corpus", "compnov.cex")
corpus = fromcex(srcfile, CitableTextCorpus, FileReader)

"""Compute token frequencies for a corpus in a given orthography, using
a given function to normalize the token.
"""
function vocabfreqs(c::CitableTextCorpus, o::T, normalizer = lowercase) where T <: OrthographicSystem
    @info("Tokenizing corpus of $(length(c.passages)) passages...")
    tkns = tokenize(c,o)
    @info("Done.")
    lex = filter(tkns) do tkn
        tkn.tokentype isa LexicalToken
    end
    tknstrings = map(lex) do tkn
        normalizer(tkn.passage.text)
    end
    freqs = countmap(tknstrings)
    sort(freqs, byvalue=true, rev=true)
end



sept = filter(corpus.passages) do p
    versionid(p.urn) == "septuagint"
end |> CitableTextCorpus

tanach = filter(corpus.passages) do psg
    versionid(psg.urn) == "masoretic"
end |> CitableTextCorpus

vulgate = filter(corpus.passages) do psg
    versionid(psg.urn) == "vulgate"
end |> CitableTextCorpus

septfreqs = vocabfreqs(sept,literaryGreek(), Kanones.knormal)

tanachfreqs = vocabfreqs(tanach,HebrewOrthography(), BiblicalHebrew.rm_accents)





# Need to write a Complutensian orthography!
#vulgatefreqs = vocabfreqs(tanach,HebrewOrthography())



# Write vocab lists to files:

septvocab = keys(septfreqs) |> collect
open("septuagint-vocab.txt","w") do io
    write(io, join(septvocab,"\n"))
end


tanachvocab = keys(tanachfreqs) |> collect
open("tanach-vocab.txt","w") do io
    write(io, join(tanachvocab,"\n"))
end

