mutable struct Layer
    minicols::Int
    neuronsper::Int
    activation::BitArray{2}
    predictions::BitArray{2}
    proximal::Array{Int16}
    psynapses::Array{Int8}
    distal::Array{Int16}
end

SPARSITY = parse(Int, readline())
SYN_THRES = 50
SYN_INC = 10
SYN_DEC = 5
SYN_CHECK = 100-SYN_INC

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

function proximalSynapses(layer::Layer, inpLen::Int, z::Int=1)
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
            psyns[i] = rand(SYN_THRES-10:SYN_THRES+60)
            splice!(allInds, findin(allInds, ind)[1])
        end
    end
    layer.proximal = pcons
    layer.psynapses = psyns
end

function activateLayer(layer::Layer, inp::BitArray{1})
    for i in 1:layer.minicols, j in 1:layer.neuronsper
        try
            for k in layer.proximal[i, j]
                if inp[k] == true && layer.psynapses[i, j, k] < SYN_THRES
                    layer.psynapses[i, j, k] += SYN_INC
                elseif inp[k] == false
                    layer.psynapses[i, j, k] -= SYN_DEC
                elseif inp[k] == true && layer.psynapses[i, j, k] >= SYN_THRES
                    layer.activation[i, j] = true
                    if layer.psynapses[i, j, k] <= SYN_CHECK
                        layer.psynapses[i, j, k] += SYN_INC
                    end
                end
            end
        catch
            print_with_color(:red, "ERROR: NoProximalSynapses: layer has no proximal synapses\n")
            break
        end
    end
end

function overlapScores(layer::Layer, inp::BitArray{1})
    allScores::Array{Int16} = []
    for i in 1:layer.minicols
        overlapScore::Int16 = 0
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
    inds::Array{Int16,1} = []
    for i in 1:layer.minicols
        if sum(layer.activation[i, :]) == layer.neuronsper
            push!(inds, Int16(i))
        end
    end
    return inds
end
