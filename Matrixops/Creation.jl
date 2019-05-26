include("Constant.jl")

    
function layer(M::Int, N::Int)
    dis = Matrix{Vector{SparseMatrixCSC}}(M, N)
    for i in eachindex(dis)
        dis[i] = [ sparse(zeros(Int8, M, N)) ]
    end # more optimized than fill!

    print_with_color(:red, "Params set to 0. Set params.")
    println("INFO: Set params using: layer_name.params = Params(...) or using a constructed Params object.")

    Layer(tuple(M,N), #dims
          dis, #distal dendrite
          Matrix{SparseVector{Int8}}(M, N), #proximal
          Params(0,0,0,0,0,0)) #params
end


function randConnectedProxSyns!(layer::Layer, inputLength::Int, synsPerNeuron::Int=1)
    #= Initialize layer's proximal connected synapses =#
    
    allInds = collect(1:inputLength)
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        layer.proximal[m, n] = SparseVector{Int8}(zeros(Int8, inputLength))
    end
    for k in 1:synsPerNeuron
        copyInds = copy(allInds)
        for m in 1:layer.dims[1], n in 1:layer.dims[2]
            ind = rand(copyInds)
            layer.proximal[m, n][ind] = 100 
            splice!(copyInds, findin(copyInds, ind)[1])
        end
    end
end


function randProxSyns!(layer::Layer, inputLength::Int, synsPerNeuron::Int=1)
    if synsPerNeuron > 1
        allInds = collect(1:inputLength)
        permRange = (layer.params.syn_thres - layer.params.syn_inc):(layer.params.syn_thres + layer.params.syn_inc)
        
        for m in 1:layer.dims[1], n in 1:layer.dims[2]
            layer.proximal[m, n] = SparseVector{Int8}(zeros(Int8, inputLength))
        end
        
        for k in 1:synsPerNeuron
            copyInds = copy(allInds)
            for m in 1:layer.dims[1], n in 1:layer.dims[2]
                ind = rand(copyInds)
                layer.proximal[m, n][ind] = rand(permRange) 
                splice!(copyInds, findin(copyInds, ind)[1])
            end
        end
    else
        randConnectedProxSyns!(layer, inputLength)
    end
end


function randCommonProxSyns!(layer::Layer, inputLength::Int, synsPerNeuron::Int=1)
    allInds = collect(1:inputLength)
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        layer.proximal[m, n] = SparseVector{Int8}(zeros(Int8, inpLen))
    end
    for k in 1:synsPerNeuron
        for m in 1:layer.dims[1]
            ind = rand(allInds)
            for n in 1:layer.dims[2]
                layer.proximal[m,n][ind] = 100
            end
            splice!(allInds, findin(allInds, ind)[1])
        end
    end
end



function distalDendrite(M::Int, N::Int)
    return sparse(zeros(Int8, M, N))
end
