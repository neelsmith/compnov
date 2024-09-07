using Tabulae, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText
using Orthography, LatinOrthography
using StatsBase, OrderedCollections

# Set these two values:
repo = pwd()
tabulaerepo = joinpath(dirname(pwd()), "Tabulae.jl")

function ds(tabulaeroot; ortho = "25")
    coreds = Tabulae.coredata(tabulaeroot; medieval = true)
    compshared = joinpath(tabulaeroot, "datasets", "complutensian", "complutensian-shared")
    comportho = joinpath(tabulaeroot, "datasets", "complutensian", "complutensian-lat$(ortho)")
    vcat(coreds.dirs, [compshared, comportho]) |> Tabulae.Dataset
end

function parser(tabulaeroot; orth = "25") 
    ds(tabulaeroot; ortho = orth)  |> tsp
end



function vulgate(reporoot)
    textsrc = joinpath(reporoot, "corpus", "compnov.cex")
    corpus = fromcex(textsrc, CitableTextCorpus, FileReader)
    filter(corpus.passages) do psg
        versionid(psg.urn) == "vulgate"
    end |> CitableTextCorpus
end




ortho = latin25()
vulg = vulgate(repo)
genesis = filter(psg -> workid(psg.urn) == "genesis", vulg.passages) |> CitableTextCorpus

tkns = tokenize(genesis, ortho)
lex = filter(tkns) do t
    t.tokentype isa LexicalToken
end



wordforms = map(x -> lowercase(x.passage.text), lex)
wordformfreqs = countmap(wordforms) |> OrderedDict
wordformssorted = sort(wordformfreqs, byvalue = true, rev = true)

wordfreqs = String[]
for k in keys(wordformssorted)
    pr = string(k, "\t", wordformssorted[k])
    push!(wordfreqs, pr)
end

open("genesis-counts.tsv", "w") do io
    write(io, join(wordfreqs,"\n"))
end


vocab = keys(wordformssorted) |> collect
open("vulgate-vocab.txt", "w") do io
    write(io, join(vocab,"\n"))
end


p = parser(tabulaerepo)
parses = map(wd -> (token = wd, results =  parsetoken(wd, p)), vocab)
failedpairs = filter(pr -> isempty(pr.results), parses)
fails = map(pr -> pr.token, failedpairs)
