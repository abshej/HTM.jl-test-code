include("Constant.jl")

    
function layer(M::Int, N::Int)    

    param = []
    dis = Matrix{Vector{SparseVector}}(M, N)
    
    for i in fieldnames(Params)
        println(i, ": ")
        push!(param, parse(Int, readline()))
    end

    for i in eachindex(dis)
        dis[i] = [ sparsevec(zeros(Int8, M, N)) ]
    end

    return Layer(tuple(M,N),
                 dis,
                 Matrix{SparseVector{Int8}}(M, N),
                 Params(param...))
end


function addProximalDendrites!(layer::Layer, inputLength::Int)

    for n in eachindex(layer.proximal)
        layer.proximal[n] = SparseVector{Int8}(zeros(Int8, inputLength))
    end

    nothing
end


function addProximalDendrite(inputLength::Int)

    return sparsevec(zeros(Int8, inputLength))
end


function addDistalDendrite(layer::Layer)

    return sparsevec(zeros(Int8, N, M))
end


function randProximalSynapses!(layer::Layer, inputLength::Int, synapsesPerNeuron::Int=1)
    
    permRange = (layer.params.syn_thres - layer.params.syn_inc):(layer.params.syn_thres + layer.params.syn_inc)

    for k in 1:synapsesPerNeuron
        allInds = shuffle(1:inputLength)
        for n in eachindex(layer.proximal)
            layer.proximal[n][allInds[n]] = rand(permRange) 
        end
    end

    nothing
end


function randPermProximalSynapses!(layer::Layer, inputLength::Int, synapsesPerNeuron::Int=1)

    for k in 1:synapsesPerNeuron
        allInds = shuffle(1:inputLength)
        for n in eachindex(layer.proximal)
            layer.proximal[n][allInds[n]] = 100 
        end
    end

    nothing
end


function randMinicolumnProximalSyns!(layer::Layer, inputLength::Int, synapsesPerNeuron::Int=1)
    
    for k in 1:synapsesPerNeuron
        allInds = shuffle(1:inputLength)
        for m in 1:layer.dims[1], n in 1:layer.dims[2]
            layer.proximal[m,n][allInds[m]] = 100
        end
    end

    nothing
end
