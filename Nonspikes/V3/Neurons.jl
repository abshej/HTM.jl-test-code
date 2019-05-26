include("Units.jl")
include("Dendrites.jl")


function totalDendrites(neuron::Neuron)
#= Total DDendrites on neuron =#

    length(neuron.distal)
end


function distalDendrite!(neuron::Neuron)
#= Add DDendrite to neuron =#

    push!(neuron.distal, DDendrite([]))
end


function proximalAct(neuron::Neuron, inpSpace)
#= true if neuron activated by proximal input =#

    return proximalSpike(neuron.proximal, inpSpace)
end


function isPredictive(neuron::Neuron, preState)
#= true if neuron is predictive =#

    actDistThres::Int = 1
    spikingDCount::Int = 0

    for dendrite in neuron.distal
        if distalSpike(dendrite, preState) == true
            spikingDCount += 1
        end
    end

    if spikingDCount >= actDistThres
        return true
    else
        return false
    end
end


function synIncrement!(neuron::Neuron, nrnID::Tuple{Int, Int})
#= Increment synaptic permanence of synapses connected to nrnID neuron =#

    synIncr::Float16 = 0.1

    for dd in eachindex(neuron.distal)
        for syn in eachindex(neuron.distal[dd].synapses)
            if neuron.distal[dd].synapses[syn].col == nrnID[1] && neuron.distal[dd].synapses[syn].nrn == nrnID[2] #&& neuron.distal[dd].synapses[syn].perm < 1.0
                neuron.distal[dd].synapses[syn].perm += synIncr
            end
        end
    end

end


function synDecrement!(neuron::Neuron, nrnID::Tuple{Int, Int})
#= Decrement synaptic permanence of synapses =#

    synDec::Float16 = 0.025
    decremented::Bool = false

    excessSyns::AbstractArray{Tuple{Int, Int}, 1} = []
    for dd in eachindex(neuron.distal)
        for syn in eachindex(neuron.distal[dd].synapses)
            if neuron.distal[dd].synapses[syn].col == nrnID[1] && neuron.distal[dd].synapses[syn].nrn == nrnID[2]
                neuron.distal[dd].synapses[syn].perm -= synDec
                decremented = true
                if neuron.distal[dd].synapses[syn].perm <= 0.0
                    # excess synapse if perm <= 0
                    push!(excessSyns, (dd, syn))
                end
            end
        end
    end

    for synID in excessSyns
        # delete all excess synapses
        splice!(neuron.distal[synID[1]].synapses, synID[2])
    end

    return decremented
end

function distalConnections!(neuron::Neuron, layerState)
#= Grow neuron's distal connections with active neurons in layerState =#

    defSynPerm::Float16 = 0.3

    distalDendrite!(neuron)

    for col in eachindex(layerState)
        for actnrn in findin(layerState[col], true)
            push!(neuron.distal[end].synapses, Syn(Int16(col), Int16(actnrn), defSynPerm))
        end
    end

end
