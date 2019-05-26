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


function distalActivation(layer::Layer, activeStates::SparseVector)
# !!!!! Needs to be updated
    predictiveStates = zeros(Int8, prod(layer.dims))
    activeStates = activeStates.nzind

    for n in eachindex(layer.distal)
        for d in eachindex(layer.distal[n])
            count = 0
            diff = layer.distal[n][d] - layer.params.syn_thres
            for i in eachindex(diff)
                if diff[i] > 0 && contains(==, activeStates, i)
                    count += 1
                    if count > layer.params.den_thres
                        predictiveStates[n] = true
                    end
                end
            end
            if count > layer.params.den_thres
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
