include("Constant.jl")

    
function layer(M::Int, N::Int)    
    param = []
    for i in fieldnames(Params)
        println(i, ": ")
        push!(param, parse(Int, readline()))
    end

    dis = Matrix{Vector{SparseMatrixCSC}}(M, N)
    for i in eachindex(dis)
        dis[i] = [ sparse(zeros(Int8, M, N)) ]
    end
    #fill!(dis, [sparse(zeros(Int8, M, N))])

    Layer(tuple(M,N), #dims
          dis, #distal dendrite
          Matrix{SparseVector{Int8}}(M, N), #proximal
          Params(param...)) #params
end



function randProxSyns!(layer::Layer, inpLen::Int, K::Int=1)

    allInds = collect(1:inpLen)
    permRange = (layer.params.syn_thres - layer.params.syn_inc):(layer.params.syn_thres + layer.params.syn_inc)

    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        layer.proximal[m, n] = SparseVector{Int8}(zeros(Int8, inpLen))
    end

    for k in 1:K
        copyInds = copy(allInds)
        for m in 1:layer.dims[1], n in 1:layer.dims[2]
            ind = rand(copyInds)
            layer.proximal[m, n][ind] = rand(permRange) 
            splice!(copyInds, findin(copyInds, ind)[1])
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



function randProxSynsTM!(layer::Layer, inpLen::Int, K::Int=1)
    allInds = collect(1:inpLen)
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        layer.proximal[m, n] = SparseVector{Int8}(zeros(Int8, inpLen))
    end
    for k in 1:K
        for m in 1:layer.dims[1]
            ind = rand(allInds)
            for n in 1:layer.dims[2]
                layer.proximal[m,n][ind] = 100
            end
            splice!(allInds, findin(allInds, ind)[1])
        end
    end
end



function distalDendrite!(layer::Layer)
    return sparse(zeros(Int8, N, M))
end
