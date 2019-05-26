include("Constant.jl")


function layer(N::Int, M::Int)    
    distal = Array{Matrix{Int8}}(N, M)
    param = []
    
    for n in 1:N, m in 1:M
        distal[n, m] = zeros(Int8, N, M)
    end
    
    for i in fieldnames(Params)
        println(i, ": ")
        push!(param, parse(Int, readline()))
    end
    
    Layer(tuple(N,M), #dims
          distal, #distal
          Array{SparseVector{Int8}}(N, M), #proximal
          Params(param...)) #params
end


function randProxSyns(layer::Layer, inpLen::Int, K::Int=1)
    allInds = collect(1:inpLen)
    permRange = layer.params.syn_thres-layer.params.syn_inc:layer.params.syn_thres+layer.params.syn_inc
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        layer.proximal[m, n] = SparseVector{Int8}(zeros(Int8, inpLen))
    end
    for k in 1:K
        copyInds = copy(allInds)
        for m in 1:layer.dims[1], n in 1:layer.dims[2]
            ind = rand(copyInds)
            layer.proximal[m, n][ind] = rand(permRange) 
            filter!(x -> x!=ind, copyInds)
        end
    end
end
