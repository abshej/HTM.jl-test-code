include("Units.jl")

function randNeuronProximalSyns!(layer::Layer, inpLen::Int)
    if inpLen < totalNeurons(layer)
        allInds = collect(1:inpLen)
        append!(allInds, rand(1:inpLen, layerUnits(layer)-inpLen))
    else
        allInds = collect(1:inpLen)
    end
    for col in eachindex(layer.minicols)
        for nrn in eachindex(layer.minicols[col].neurons)
            indHolder = rand(allInds)
            push!(layer.minicols[col].neurons[nrn].proximal.synapses, Syn(0, indHolder, 1.0))
            splice!(allInds, findin(allInds, indHolder)[1])
        end
    end
end



function randMinicolProximalSyns!(layer::Layer, inpLen::Int)
    allInds = collect(1:inpLen)
    for col in eachindex(layer.minicols)
        indHolder = rand(allInds)
        for nrn in eachindex(layer.minicols[col].neurons)
            push!(layer.minicols[col].neurons[nrn].proximal.synapses, indHolder)
        end
        filter!(ind -> ind!=indHolder, allInds)
    end
end


function proximalSyns!(layer::Layer, inpLen::Int; unit::String="neuron")
    if lowercase(unit) == "neuron"
        randNeuronProximalSyns!(layer, inpLen)
    elseif lowercase(unit) == "minicol"
        randMinicolProximalSyns!(layer, inpLen)
    else
        error("Wrong connection type")
    end
end



function clearProximalSyns!(layer::Layer)
    for col in eachindex(layer.minicols)
        for nrn in eachindex(layer.minicols[col].neurons)
            layer.minicols[col].neurons[nrn].proximal.synapses = []
        end
    end
end
