struct Params
    syn_def::Int
    syn_inc::Int
    syn_dec::Int
    syn_thres::Int
    den_thres::Int
    sparsity::Int
end


mutable struct Layer
    dims::Tuple{Int, Int}
    distal::Matrix{Vector{SparseVector{Int8}}}
    proximal::Matrix{SparseVector{Int8}}

    params::Params
end


RawInput = Union{BitArray, Array{Bool}}
