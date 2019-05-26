include("Units.jl")


function totalSynapses(dendrite::Union{DDendrite, PDendrite})
#= Returns total number of synapses on dendrite =#

    length(dendrite.synapses)
end


function synapse!(dendrite::DDendrite, nrnInd::Tuple{Int, Int})
#= Grow symbolic synapse between dendrite and neuron at neuronIndex =#

    defaultSynPerm::Float16 = 0.3
    
    push!(dendrite.synapses, Syn(Int16(nrnInd[1]), Int16(nrnInd[2]), defaultSynPerm))
end


function distalSpike(dendrite::DDendrite, preState)
#= Returns true if distal dendrite spikes =#

    minSCount::Int = 1
    sCount::Int = 0
    
    for syn in dendrite.synapses
        if preState[syn.col][syn.nrn] == true
            sCount += 1
        end
    end

    if sCount >= minSCount # if active synapses exceed the spike threshold
        return true # the dendrite spikes
    else
        return false
    end
end


function proximalSpike(dendrite::PDendrite, inpSpace)
#= Returns true if proximal dendrite spikes due to FF input =#
    
    spike::Bool = false
    
    for ind in dendrite.synapses
        if inpSpace[ind] == true
            spike = true
        end
    end

    return spike
end
