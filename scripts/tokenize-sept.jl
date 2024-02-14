# Tokenize the septuagint
repo = pwd() 


using CitableBase, CitableCorpus, CitableText
srcfile = joinpath(repo,"corpus", "compnov.cex")
corpus = fromcex(srcfile, CitableTextCorpus, FileReader)
sept = filter(corpus.passages) do p
    versionid(p.urn) == "septuagint"
end |> CitableTextCorpus

using Orthography, PolytonicGreek
ortho = literaryGreek()
tkns = tokenize(sept,ortho)


lex = filter(tkns) do tkn
    tkn.tokentype isa LexicalToken
end

tknstrings = map(lex) do tkn
    lowercase(tkn.passage.text)
end

using StatsBase
using OrderedCollections
freqs = countmap(tknstrings) |> OrderedDict
sorted = sort(freqs, byvalue=true, rev=true)

vocab = keys(sorted) |> collect