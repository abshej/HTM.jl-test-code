struct Params
    syn_inc::Int
    syn_dec::Int
    syn_thres::Int
    den_syn_thres::Int
    sparsity::Int
end

mutable struct Layer
    dims::Tuple{Int, Int}
    distal::Array{Matrix{Int8}, 2}
    proximal::Array{SparseVector{Int8}, 2}
    params::Params
end
