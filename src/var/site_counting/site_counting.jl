# Types and methods for counting mutations
# ========================================
#
# This file is a part of BioJulia.
# License is MIT: https://github.com/BioJulia/Bio.jl/blob/master/LICENSE.md

include("site_types.jl")

typealias FourBitAlphs Union{DNAAlphabet{4},RNAAlphabet{4}}
typealias TwoBitAlphs Union{DNAAlphabet{2},RNAAlphabet{2}}
typealias NucAlphs Union{DNAAlphabet, RNAAlphabet}

# Includes for naieve site counting.
include("naive/is_site.jl")
include("naive/count_sites_naive.jl")

"""
    count_sites{T<:Site}(::Type{T}, a::BioSequence, b::BioSequence)

Mutations are counted using the `count_sites` method.

If the concrete site case type inherits from NoPairDel, then the result will
be a simple integer value of the number of counts of site.

If the concrete site case type inherits from PairDel, then the result
will be a tuple. As a result, counting methods for such types also count and
return the number of sites which could not be unambiguously determined.
This second count is important for some downstream purposes, for example
evolutionary/genetic distance computations in which pairwise deletion of
ambiguous sites is necessary.
"""
function count_sites{T<:Site}(::Type{T}, a::BioSequence, b::BioSequence)
    return count_sites_naive(T, a, b)
end

"""
    count_sites{T<:NoPairDel}(::Type{T}, a::EachWindowIterator, b::EachWindowIterator)

A method of the count_sites function for counting sites of SiteType `T` between two aligned
sequences.

Crucially, this method accepts two EachWindowIterators as parameters `a` and `b`
instead of two `BioSequence`s. As a result, the two sequences are iterated over
with a sliding window, and a site count computed for each window.

This function returns two vectors, one with the ranges
"""
function count_sites{T<:Site}(::Type{T}, a::EachWindowIterator, b::EachWindowIterator)
    itr = zip(a, b)
    results = Vector{IntervalValue{Int, Int}}(length(itr))
    i = 1
    for (wina, winb) in itr
        interval = wina[1]
        results[i] = IntervalValue(first(interval), last(interval), count_sites(T, wina[2], winb[2]))
        i += 1
    end
    return results
end

function count_sites{T<:Mutation}(::Type{T}, a::EachWindowIterator, b::EachWindowIterator)
    itr = zip(a, b)
    len = length(itr)
    results = Vector{IntervalValue{Int}}(len)
    undetermined = Vector{IntervalValue{Int}}(len)
    i = 1
    for (wina, winb) in itr
        interval = wina[1]
        counts = count_sites(T, wina[2], winb[2])
        results[i] = IntervalValue(first(interval), last(interval), counts[1])
        undetermined[i] = IntervalValue(first(interval), last(interval), counts[2])
        i += 1
    end
    return results, undetermined
end

"Count the number of sites between two nucleotide sequences using a sliding window."
function count_sites{T<:Site}(::Type{T}, a::BioSequence, b::BioSequence, width::Int, step::Int)
    awindows = eachwindow(a, width, step)
    bwindows = eachwindow(b, width, step)
    return count_sites(T, awindows, bwindows)
end

"""
Count the number of mutations between nucleotide sequences in a pairwise manner.
"""
function count_sites{T<:Site,A<:Alphabet}(::Type{T}, sequences::Array{BioSequence{A}})
    len = length(sequences)
    counts = PairwiseListMatrix(Int, len, false)
    @inbounds for i in 1:len, j in (i + 1):len
        counts[i, j] = count_sites(T, sequences[i], sequences[j])
    end
    return counts
end

"""
Count the number of mutations between nucleotide sequences in a pairwise manner,
using a sliding window of a given width and step.
"""
function count_sites{T<:Site,A<:Alphabet}(::Type{T}, sequences::Array{BioSequence{A}}, width::Int, step::Int)
    len = length(sequences)
    counts = PairwiseListMatrix(Vector{IntervalValue{Int}}, len, false)
    @inbounds for i in 1:len, j in (i + 1):len
        counts[i, j] = count_sites(T, sequences[i], sequences[j], width, step)
    end
    return counts
end

"""
Count the number of mutations between nucleotide sequences in a pairwise manner.
"""
function count_sites{T<:Mutation,A<:Alphabet}(::Type{T}, sequences::Array{BioSequence{A}})
    len = length(sequences)
    counts = PairwiseListMatrix(Int, len, false)
    undetermined = PairwiseListMatrix(Int, len, false)
    @inbounds for i in 1:len, j in (i + 1):len
        counts[i, j], undetermined[i, j] = count_sites(T, sequences[i], sequences[j])
    end
    return counts, undetermined
end

"""
Count the number of mutations between nucleotide sequences in a pairwise manner,
using a sliding window of a given width and step.
"""
function count_sites{T<:Mutation,A<:Alphabet}(::Type{T}, sequences::Array{BioSequence{A}}, width::Int, step::Int)
    len = length(sequences)
    counts = PairwiseListMatrix(Vector{IntervalValue{Int}}, len, false)
    undetermined = PairwiseListMatrix(Vector{IntervalValue{Int}}, len, false)
    @inbounds for i in 1:len, j in (i + 1):len
        counts[i, j], undetermined[i, j] = count_sites(T, sequences[i], sequences[j], width, step)
    end
    return counts, undetermined
end

"Count the number of sites of a given SiteType `T` in a biological sequence."
function count_sites{T<:Site}(::Type{T}, seq::BioSequence)
    return count_sites_naive(T, seq)
end
