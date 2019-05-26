include("Constant.jl")


function proximalActivation(layer::Layer, input::RawInput)

    activeStates = zeros(Int8, prod(layer.dims))
    input = Set(sparsevec(input).nzind)

    for n in eachindex(layer.proximal)
        if length(intersect(Set(layer.proximal[n].nzind), input)) > 0
            activeStates[n] = Int8(1)
        end
    end
    
    return sparsevec(activeStates)
end


function permdiff(permanence::Int8, threshold::Int8)

    if permanence - threshold >= 0
        return true
    else
        return false
    end
end


function distalActivation(layer::Layer, activeStates::SparseVector)

    predictiveStates = zeros(Int8, prod(layer.dims))
    activeStates = activeStates.nzind
    den_thres = layer.params.den_thres
    syn_thres = Int8(layer.params.syn_thres - 1)

    #connected::Vector = []
    #=for i in eachindex(layer.distal)
        push!(connected, [])
        for j in eachindex(layer.distal[i])
            push!(connected[end], isless.(syn_thres, layer.distal[i][j]))
        end
    end =#
    
    for n in eachindex(layer.distal)
        for d in eachindex(layer.distal[n])
            count = 0
            if length(findin((isless.(syn_thres, layer.distal[n][d])).nzind, activeStates)) > den_thres
                predictiveStates[n] = true
                break
            end
        end
    end

    return sparsevec(predictiveStates)
end


function searchDendrites(dendrites::Vector, indices::Vector)

    dendriteIDs::Vector = []
    
    for i in indices
        for d in eachindex(dendrites)
            if !iszero(dendrites[d][i])
                push!(dendriteIDs, d)
                break
            else
                push!(dendriteIDs, 0)
            end
        end
    end

    return dendriteIDs
end


function distalUpdate(layer::Layer, priorActiveStates::SparseVector, predictions::SparseVector, currentActiveStates::SparseVector)

    priorStates = priorActiveStates.nzind
    correctPreds = currentActiveStates.nzind
    wrongPreds = copy(predictions)
    wrongPreds[intersect(currentActiveStates.nzind, predictions.nzind)] = 0
    dropzeros!(wrongPreds)
    wrongPreds = wrongPreds.nzind
    upperBound = 100 - layer.params.syn_inc

    for i in correctPreds
        dendriteIDs = searchDendrites(layer.distal[i], priorStates)
        for a in eachindex(dendriteIDs)
            if dendriteIDs[a] != 0
                if layer.distal[i][dendriteIDs[a]][priorStates[a]] <= upperBound
                    layer.distal[i][dendriteIDs[a]][priorStates[a]] += layer.params.syn_inc
                else
                    layer.distal[i][dendriteIDs[a]][priorStates[a]] = 100
                end
            else
                layer.distal[i][end][priorStates[a]] = layer.params.syn_def
            end
        end
    end
    
    for i in wrongPreds
        dendriteIDs = searchDendrites(layer.distal[i], priorStates)
        for a in eachindex(dendriteIDs)
            if dendriteIDs[a] != 0
                if layer.distal[i][dendriteIDs[a]][priorStates[a]] >= layer.params.syn_dec
                    layer.distal[i][dendriteIDs[a]][priorStates[a]] -= layer.params.syn_dec
                else
                    layer.distal[i][dendriteIDs[a]][priorStates[a]] = 0
                end
            end
        end
    end
    
    nothing
end
