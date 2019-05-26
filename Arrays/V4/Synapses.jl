include("Core.jl")

function proximalSyns!(layer::Layer, inpLen::Int, z::Int=1)
    #no of minicolumns, no of neurons, inp length, no of proximal connections per neuron
    pcons::Array{Int16, 3} = zeros(Int, layer.minicols, layer.neuronsper, z)
    allIndxs = Int16.(collect(1:inpLen))
    if inpLen < length(layer.activation)
        append!(allInds, rand(1:allInds, ((n*w)-inpLen)))
    end
    for j in 1:z
        allInds = copy(allIndxs)
        for i in eachindex(pcons)
            ind = rand(allInds)
            pcons[i] = ind
            splice!(allInds, findin(allInds, ind)[1])
        end
    end
    layer.proximal = pcons
end

function proximalSynsPerms!(layer::Layer, inpLen::Int, z::Int=1)
    #no of minicolumns, no of neurons, inp length, no of proximal connections per neuron
    pcons::Array{Int16, 3} = zeros(Int, layer.minicols, layer.neuronsper, z)
    psyns::Array{Int8, 3} = zeros(Int, layer.minicols, layer.neuronsper, z)
    allIndxs = Int16.(collect(1:inpLen))
    if inpLen < length(layer.activation)
        append!(allInds, rand(1:allInds, ((n*w)-inpLen)))
    end
    for j in 1:z
        allInds = copy(allIndxs)
        for i in eachindex(pcons)
            ind = rand(allInds)
            pcons[i] = ind
            psyns[i] = rand(SYN_THRES-10:SYN_THRES+10)
            splice!(allInds, findin(allInds, ind)[1])
        end
    end
    layer.proximal = pcons
    layer.pperms = psyns
end

function updateDistalConnections!(layer::Layer, actstates)
    #layer, previous active states
    predstates = predictiveNeurons(layer)
    for i in layer.minicols, j in layer.neuronsper
        if layer.activation[i, j] == true
            for q in actstates
                if contains(==, layer.distal[i, j], q)
                    layer.dperms[i, j, findin(layer.distal[i, j], q)] += SYN_INC
                else
                    push!(layer.distal[i, j], q)
                end
            end
        else #layer.activation[i, j] == false
            if contains(==, predstates, (i, j))
                for q in predstates
                    for o in actstates
                        layer.dperms[i, j, findin(layer.distal[i, j], o)] -= SYN_DEC
                    end
                end
            end
        end
    end
end
