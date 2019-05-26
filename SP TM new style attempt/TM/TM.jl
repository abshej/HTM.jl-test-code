struct Params
    def_syn_perm::Int
    syn_thres
    syn_inc
    syn_dec
    den_syn_thres
end

mutable struct TMLayer
    dims::Tuple{Int, Int}
    distal::Matrix{Vector{SparseMatrixCSC{Int8}}}
    proximal::Matrix{Int}
    params::Params
end
    
