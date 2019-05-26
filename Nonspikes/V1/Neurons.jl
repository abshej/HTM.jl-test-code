include("Units.jl")
include("Dendrites.jl")


function totalDendrites(neuron::Neuron)
#= Returns total number of distal dendrites on neuron =#

    length(neuron.distal)
end


function distalDendrite!(neuron::Neuron)
#= Add a distal dendrite to a neuron =#

    push!(neuron.distal, DDendrite([]))
end


function computeNeuronFF(neuron::Neuron, inpSpace)
#= Return true if neuron is activated using FF input to proximal dendrite =#

    return proximalSpike(neuron.proximal, inpSpace) #since we use only single proximal dendrite
end


function predictions(neuron::Neuron, preState)
#= Returns true if neuron is put in predictive state using distal dendrites =#
    
    dCount::Int = 0
    
    for dendrite in neuron.distal
        if distalSpike(dendrite, preState) == true
            dCount += 1
        end
    end

    if dCount > 0 # if any distal dendrite is spiking
        return true # the neuron goes into predictive state
    else
        return false
    end
end


function synIncrement!(neuron::Neuron, nrnID::Tuple{Int, Int})
#= Increments synaptic permanence for synapses on neuron that connect to nrnID neuron =#
    
    incremented::Bool = false
    
    for dd in eachindex(neuron.distal)
        for syn in eachindex(neuron.distal[dd].synapses)
            if neuron.distal[dd].synapses[syn].col == nrnID[1] && neuron.distal[dd].synapses[syn].nrn == nrnID[2]
                neuron.distal[dd].synapses[syn].perm += 0.1
                incremented = true
            end
        end
    end

    return incremented
end


function growDistal!(neuron::Neuron, preState)
#= Grow distal connections of neuron with active neurons indicated by preState =#
    
    maxDistSyns::Int = 100

    # iterate over each active neuron index in preState
    for col in eachindex(preState)
        for actnrn in findin(preState[col], true)

            if length(neuron.distal) == 0
            # if neuron has no distal dendrite then grow one    
                distalDendrite!(neuron)
            end

            #synIncrement!(neuron, (col, actnrn))

            incremented = synIncrement!(neuron, (col, actnrn))

            if incremented == false # if no synaptic increment took place

                if length(neuron.distal[end].synapses) > maxDistSyns # if max synapses on dendrite reached roughly

                    distalDendrite!(neuron) # grow new dendrite
                    push!(neuron.distal[end].synapses, Syn(Int16(col),Int16(actnrn),Float16(0.3))) # add synapse on the newly grown dendrite
                else
                    push!(neuron.distal[end].synapses, Syn(Int16(col),Int16(actnrn),Float16(0.3))) # else add synapse on the last dendrite
                end
            end

        end
    end

end
    


#=
OLD FUNCTIONS


function growDistal(neuron::Neuron, preState)
#= Grow distal connection with neurons active during preState =#
    
    maxDistSyns::Int = 100
    
    for col in eachindex(preState)
        for actnrn in findin(preState[col], true)

            # if there are no distal dendrites present on the neuron
            if length(neuron.distal) == 0
                distalDendrite!(neuron)
            end
            
            # if max synapses on dendrite reached
            if length(neuron.distal[end].synapses) > maxDistSyns 
                distalDendrite!(neuron) # add a distal dendrite
                push!(neuron.distal[end].synapses, [col, actnrn, Float16(0.3)]) # add synapse to newly added dendrite
            else
                push!(neuron.distal[end].synapses, [col, actnrn, Float16(0.3)]) # add synapse to last distal dendrite
            end
        end
    end
    
end
=#
