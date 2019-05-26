mutable struct Layer
    minicols::Int
    neuronsper::Int
    activation::BitArray{2}
    predictions::BitArray{2}
    proximal::Array
    distal::Array
end

SPARSITY = parse(Int, readline())

function layer(n::Int, w::Int)
    #no of minicolumns, no of neurons per minicolumn
    Layer(n, w, falses(n, w), falses(n, w), [], [])
end

function displayLayer(layer::Layer)
    print_with_color(:green, "Layer INFO:\n")
    println("Layer Minicolumns:      ", layer.minicols)
    println("Neurons per minicolumn: ", layer.neuronsper)
    print_with_color(:green, "Layer INFO: Active states:\n")
    display(layer.activation)
    print_with_color(:green, "Layer INFO: Predictive states:\n")
    display(layer.predictions)
end

function proximalConnections(layer::Layer, inpLen::Int, z::Int=1)
    #no of minicolumns, no of neurons, inp length, no of proximal connections per neuron
    pcons::Array{Int, 3} = zeros(Int, layer.minicols, layer.neuronsper, z)
    allIndxs = collect(1:inpLen)
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

function activateLayer(layer::Layer, inp::BitArray{1})
    for i in 1:layer.minicols, j in 1:layer.neuronsper
        try
            for k in layer.proximal[i, j]
                if inp[k] == true
                    layer.activation[i, j] = true
                    break
                end
            end
        catch
            print_with_color(:red, "ERROR: NoProximalSynapses: layer has no proximal synapses\n")
            break
        end
    end
end

function overlapScores(layer::Layer, inp::BitArray{1})
    allScores::Array = []
    for i in 1:layer.minicols
        overlapScore::Int = 0
        for j in 1:layer.neuronsper
            for k in layer.proximal[i, j]
                if inp[k] == true
                    overlapScore += 1
                    break
                end
            end
        end
        push!(allScores, overlapScore)
    end
    return allScores
end

function activateSP(layer::Layer, inp::BitArray{1})
    overlapScore = overlapScores(layer, inp)
    sortedOverlapScores = sort(overlapScore, rev=true)
    for actcol in 1:SPARSITY
        ind = findin(overlapScore, sortedOverlapScores[1])[1]
        layer.activation[ind, :] = true
        shift!(sortedOverlapScores)
        overlapScore[ind] = 0
    end
end

function restLayer(layer::Layer)
    layer.activation = falses(layer.minicols, layer.neuronsper)
end

function activeMinicols(layer::Layer)
    inds::Array{Int,1} = []
    for i in 1:layer.minicols
        if sum(layer.activation[i, :]) == layer.neuronsper
            push!(inds, i)
        end
    end
    return inds
end
