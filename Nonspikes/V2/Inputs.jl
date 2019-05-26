include("Units.jl")

function randInpSynapses!(layer::Layer, inpLen::Int)
#= Connect proximal dendrites of al neurons in layer with random inpLen indices =#
    
    if inpLen < layerUnits(layer)
        allInds = collect(1:inpLen)
        append!(allInds, rand(1:inpLen, layerUnits(layer)-inpLen))
    else
        allInds = collect(1:inpLen)
    end
    
    for col in eachindex(layer.minicols)
        for nrn in eachindex(layer.minicols[col].neurons)
            indHolder = rand(allInds)
            push!(layer.minicols[col].neurons[nrn].proximal.synapses, indHolder)

            splice!(allInds, findin(allInds, indHolder)[1])

          #=useful if inpLen >= layerUnits(layer)
            filter!(ind -> ind!=indHolder, allInds)=#
            
        end
    end

end

function minicolInpSynapses!(layer::Layer, inpLen)

    allInds = collect(1:inpLen)

    for col in eachindex(layer.minicols)
        indHolder = rand(allInds)
        for nrn in eachindex(layer.minicols[col].neurons)
            push!(layer.minicols[col].neurons[nrn].proximal.synapses, indHolder)
        end
        filter!(ind -> ind!=indHolder, allInds)
    end
end

function removeInpSynapses!(layer::Layer)
#= Remove layer's proximal connections =#
    
    for col in eachindex(layer.minicols)
        for nrn in eachindex(layer.minicols[col].neurons)
            layer.minicols[col].neurons[nrn].proximal.synapses = []
        end
    end

end
