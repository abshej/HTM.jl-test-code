mutable struct Layer
    minicols::Int
    neuronsper::Int
    activation::BitArray{2}
    predictions::BitArray{2}
    proximal::Array{Int16}
    pperms::Array{Int8}
    distal::Array{Int16}
    dperms::Array{Int8}
end

SPARSITY = 1
SYN_THRES = 50
SYN_INC = 10
SYN_DEC = 5
DISTAL_THRES = 1

function depolarizeLayer!(layer::Layer)
    #layer
    for i in layer.minicols, j in layer.neuronsper
        count::Int = 0
        for k in layer.distal[i, j]
            if layer.activation[k...] == true
                count += 1
            end
        end
        if count > DISTAL_THRES
            layer.predictions[i, j] == true
        end
    end
end

function activateLayer!(layer::Layer, inp::Union{BitArray{1}, Array{Bool, 1}})
    for i in 1:layer.minicols, j in 1:layer.neuronsper
        for k in layer.proximal[i, j]
            if inp[k] == true
                layer.activation[i, j] = true
                break
            else
                layer.activation[i, j] = false
            end
        end
    end
end

function activateLayerPerms!(layer::Layer, inp::Union{BitArray{1}, Array{Bool, 1}})
    for i in 1:layer.minicols, j in 1:layer.neuronsper
        for k in layer.proximal[i, j]
            if inp[k] == true && layer.pperms[i, j, k] < SYN_THRES
                layer.pperms[i, j, k] += SYN_INC
            elseif inp[k] == true && layer.pperms[i, j, k] >= SYN_THRES
                layer.activation[i, j] = true
                try layer.pperms[i, j, k] += SYN_INC end
            elseif inp[k] == false
                try layer.pperms[i, j, k] -= SYN_DEC end
            end
        end
    end
end

function overlapScores(layer::Layer, inp::Union{BitArray{1}, Array{Bool, 1}})
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

function overlapScoresPerms(layer::Layer, inp::Union{BitArray{1}, Array{Bool, 1}})
    allScores::Array{Int16} = []
    for i in 1:layer.minicols
        overlapScore::Int16 = 0
        for j in 1:layer.neuronsper
            for k in layer.proximal[i, j]
                if inp[k] == true && layer.pperms[i, j, k] >= SYN_THRES
                    overlapScore += 1
                    break
                end
            end
        end
        push!(allScores, overlapScore)
    end
    return allScores
end


function activateSP!(layer::Layer, inp::Union{BitArray{1}, Array{Bool, 1}})
    overlapScore = overlapScores(layer, inp)
    sortedOverlapScores = sort(overlapScore, rev=true)
    for actcol in 1:SPARSITY
        ind = findin(overlapScore, sortedOverlapScores[1])[1]
        layer.activation[ind, :] = true
        shift!(sortedOverlapScores)
        overlapScore[ind] = 0
    end
end

function restLayer!(layer::Layer)
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

function activeNeurons(layer::Layer)
    actneurons::Vector{Tuple} = []
    for i in Set(sparse(layer.activation).rowval)
        for j in findin(layer.activation[i, :], true)
            push!(actneurons, (i, j))
        end
    end
    return actneurons
end

function predictiveNeurons(layer::Layer)
    predneurons::Vector{Tuple} = []
    for i in Set(sparse(layer.predictions).rowval)
        for j in findin(layer.activation[i, :], true)
            push!(predneurons, (i, j))
        end
    end
    return predneurons
end

function cleanConnections!(layer::Layer)
    for i in 1:layer.minicolumns, j in 1:layer.neuronsper
        clearcons::Array = []
        for k in eachindex(layer.pperms[i, j])
            if layer.pperms[i, j, k] <= 0
                push!(clearcons, k)
            end
        end
        for m in clearcons
            splice!(layer.pperms[i, j], m)
            splice!(layer.proximal[i, j], m)
        end
        clearcons = []
        for n in eachindex(layer.dperms[i, j])
            if layer.dperms[i, j, n] <= 0
                push!(clearcons, n)
            end
        end
        for o in clearcons
            splice!(layer.dperms[i, j], o)
            splice!(layer.distal[i, j], o)
        end
    end
end

function proximalSynsTM!(layer::Layer)
    pcons::Array = zeros(Int, layer.minicols, layer.neuronsper)
    allInds = collect(1:layer.minicols)
    for i in 1:layer.mincols
        ind = rand(allInds)
        pcons[i, :] = ind
        filter!(x -> x!=ind, allInds)
    end
    layer.pperms = pcons
end

function activateTM!(layer::Layer, inp::Union{BitArray{1}, Array{Bool, 1}})
    for i in 1:layer.minicols
        if inp[layer.proximal[i, 1]] == true
            if contains(==, layer.predictions[i, :], true)
                layer.activation[i, findin(layer.predictions[i, :], true)[1]] = true
            else
                #mincol bursting
                layer.activation[i, :] = true
            end
        end
    end
end

macro SP(layer, inp)
    activateSP!(layer, inp)
end
