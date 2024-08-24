using Kanones, CitableParserBuilder
using CitableBase, CitableCorpus, CitableText
using Orthography, PolytonicGreek
using StatsBase, OrderedCollections

parserfile = joinpath(pwd(), "scratch", "core-attic-2024-07-09.cex")
parser = fromcex(parserfile, KanonesStringParser)

ortho = literaryGreek()


# Make sure thestwo directories `repo` and `kroot` have the right
# values for the root of the compnov repository and the root of the 
# Kanones.jl repository:

#desk = repo |> dirname |> dirname 
#kroot = joinpath(desk, "greek-work", "Kanones.jl")

repo = pwd()
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


parses = map(wd -> parsetoken(wd, parser), vocab)

parsetoken(vocab[1], parser)

freqs = []
for k in keys(wordformssorted) 
    push!(freqs, join([k, wordformssorted[k]], "|"))
end
open("sept-wordfreqs.cex", "w") do io
    write(io, join(freqs, "\n"))
end

#parsedtokens = parsecorpus(sept, parser)



# Don't need this for parsing.
#=
 tknidx = corpusindex(sept, ortho)

uclist = filter(wd -> isuppercase(wd.passage.text[1]), lex)
lclist = filter(wd -> ! isuppercase(wd.passage.text[1]), lex)
lcforms = map(lclist) do tkn
    tkn.passage.text
end


trueuc = filter(uclist) do tkn
    ! (lowercase(tkn.passage.text) in lcforms)
end


trueucforms = map(trueuc) do tkn
    tkn.passage.text
end |> unique

uclist = filter(wd -> isuppercase(wd[1]), vocab)
=#




# bigdict = lexemedictionary(parsedtokens.analyses, tknidx)


#=
s = "ποιῆσαι"
parses = parsewordlist(vocab, parser)
ax = parses[3][1]

nonempty = filter(a -> ! isempty(a), parses)
poiesai = filter(p -> p[1].token == s, nonempty)[1]

poiew = poiesai[1].lexeme

poiewforms = filter(nonempty) do p
    p[1].lexeme == poiew
end


poiewstrings = map(poiewforms) do p
    p[1].token
end

join(poiewstrings,"\n") |> println

join(tknidx[poiewstrings[1]], "\n") |> println
=#





a = parsedtokens.analyses[1] 

#=
fails = []
for (wd, alist) in zip(vocab, parses)   
    if isempty(alist)
        push!(fails, wd)qwesdzx
    end
end


failfreqs = map(fails) do wd
    string(wd, " ", wordformfreqs[wd])
end

open("failed-counts.txt", "w") do  io
    write(io, join(failfreqs, "\n"))
end


testcorp = CitableTextCorpus(sept.passages[1:5])

testparses = parsecorpus(testcorp, parser)

typeof(testparses.analyses[1])
=#