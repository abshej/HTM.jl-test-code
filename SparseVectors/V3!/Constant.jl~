struct Params
    syn_def::Int8
    syn_inc::Int8
    syn_dec::Int8
    syn_thres::Int8
    dist_thres::Int8
    sparsity::Int8
end


mutable struct Layer
    dims::Tuple{Int, Int}
    distal::Vector{Vector{SparseVector{Int8}}}
    proximal::Vector{SparseVector{Int8}}

    params::Params
end


RawInput = Union{BitArray, Array{Bool}}
