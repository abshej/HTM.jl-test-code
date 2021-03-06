include("Constant.jl")


function distDen!(layer::Layer)
    distal = sparse(zeros(Int8, N, M))
    for i in eachindex(layer.distal)
        push!(layer.distal[i], distal)
    end
end

    
function layer(N::Int, M::Int)    
    param = []
    for i in fieldnames(Params)
        println(i, ": ")
        push!(param, parse(Int, readline()))
    end

    dis = Matrix{Vector{SparseMatrixCSC}}(N, M)
    for i in eachindex(dis)
        dis[i] = [sparse(zeros(Int8, N, M))]
    end
    Layer(tuple(N,M), #dims
          dis, #distal dendrite
          Array{SparseVector{Int8}}(N, M), #proximal
          Params(param...)) #params
end


function randProxSyns!(layer::Layer, inpLen::Int, K::Int=1)
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

function randStaticProxSyns!(layer::Layer, inpLen::Int, K::Int=1)
    allInds = collect(1:inpLen)
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        layer.proximal[m, n] = SparseVector{Int8}(zeros(Int8, inpLen))
    end
    for k in 1:K
        copyInds = copy(allInds)
        for m in 1:layer.dims[1], n in 1:layer.dims[2]
            ind = rand(copyInds)
            layer.proximal[m, n][ind] = 100 
            filter!(x -> x!=ind, copyInds)
        end
    end
end
