mutable struct Cell
    activation::Bool
    synapses::AbstractArray
end


function generateLayer(N::Int)
    [Cell(false, []) for i in 1:N]
end

function makeConnections!(layer, inputlayer)
    for i in eachindex(layer)
        push!(layer[i].synapses, rand(eachindex(inputlayer)))
    end
end

function updateLayer!(layer, inputlayer, sparsity)
    countIndex = []
    for cell in eachindex(layer)
        count = 0
        for synapse in eachindex(layer[cell].synapses)
            if inputlayer[layer[cell].synapses[synapse]] == true
                count += 1
            end
            push!(countIndex, (count, cell))
            count = 0
        end
    end
    a = sort([countIndex[i][1] for i in eachindex(countIndex)], rev=true)
    actcount = 0
    for i in eachindex(countIndex)
        dowebreak = false
        for j in eachindex(layer)
            if countIndex[j][1] == a[i]
                layer[i].activation = true
                actcount += 1
                if actcount == sparsity
                    dowebreak = true
                    break
                end
            end
        end
        if dowebreak == true
            break
        end
    end
        
end

function saveState(layer)
    indices = []
    for i in eachindex(layer)
        if layer[i].activation == true
            push!(indices, i)
        end
    end
    return indices
end

function resetLayerState!(layer)
    for i in eachindex(layer)
        layer[i].activation = false
    end
end

function makeSPConnections!(layer, inplayer, N)
    for i in eachindex(layer)
        indices = Set()
        while length(indices)!=N
            push!(indices, rand(eachindex(inplayer)))
        end
        for j in indices
            push!(layer[i].synapses, j)
        end
    end
end

    
