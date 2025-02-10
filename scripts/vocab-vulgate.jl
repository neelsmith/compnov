using CitableBase, CitableText, CitableCorpus
using Downloads, Markdown

repo = pwd()
localparser = true

function vulgate(reporoot)
    textsrc = joinpath(reporoot, "corpus", "compnov.cex")
    corpus = fromcex(textsrc, CitableTextCorpus, FileReader)
    filter(corpus.passages) do psg
        versionid(psg.urn) == "vulgate"
    end |> CitableTextCorpus
end
corpus = vulgate(repo)



using Orthography, LatinOrthography

tkns = tokenize(corpus, latin25())
lex = filter(t -> t.tokentype isa LexicalToken, tkns)
totallex = length(lex)

using StatsBase, OrderedCollections

countsraw = map(tkn -> tkn.passage.text, lex) |> countmap |> OrderedDict
counts = sort(countsraw, byvalue = true, rev = true)
distincttokens = length(counts)


@info("Total number of lexical tokens: $(totallex)")
@info("Distinct tokens: $(distincttokens)")


using CitableParserBuilder, Tabulae

tabulaerepo = joinpath(dirname(pwd()), "Tabulae.jl")
isdir(tabulaerepo)


function getparser(localparser::Bool = localparser; tabulae = tabulaerepo)
    if localparser
        parserfile = joinpath(tabulae, "scratch", "confessions-current.cex")
        stringParser(parserfile, FileReader)
    else
        tabulaeurl = "http://shot.holycross.edu/morphology/confessions-current.cex"
        stringParser(tabulaeurl, UrlReader)
    end
end




function collectfails(p, words)
    fails = []
    for (i, wd) in enumerate(words)
        if mod(i, 25) == 0
            @info("$(i)/$(length(words))")
        end
        reslts = parsetoken(lowercase(wd), p)
        if isempty(reslts)
            @warn("Failed to parse $(wd)")
            push!(fails, wd)
        end
    end
    fails
end


function writefailcounts(badlist, countdict; fname = "fails.cex")
    failsfreqs = map(badlist) do s
        string(s, "|", countdict[s])
    end
    open(fname, "w") do io
        write(io, join(failsfreqs,"\n"))
    end
end




wordlist = collect(keys(counts))


pns = filter(wordlist) do w
    isuppercase(w[1]) && 
    ! (lowercase(w) in wordlist)
end

lclist = filter(w -> islowercase(w[1]), wordlist)
testlist = lclist[1:5000]

testlist[1:100]
parser = getparser(true)


@time fails = collectfails(parser, testlist)
writefailcounts(fails, counts)


@time allfails = collectfails(parser, lclist)
writefailcounts(allfails, counts; fname = "fails-all.cex")




pnfreqs = map(pns) do pn
    string(pn, "|", counts[pn])
end
open("pns-freqs.cex", "w") do io
    write(io, join(pnfreqs,"\n"))
end