include("Units.jl")


function totalSynapses(dendrite::Union{DDendrite, PDendrite})
#= Returns total number of synapses on dendrite =#

    length(dendrite.synapses)
end


function distalSpike(dendrite::DDendrite, preState)
#= Returns true if distal dendrite spikes =#

    synCnctdThres::Float16 = 0.4 # synaptice connection threshold
    ddActThres::Int = 1

    sCount::Int = 0

    for syn in dendrite.synapses
        if preState[syn.col][syn.nrn] == true && syn.perm >= synCnctdThres
            sCount += 1
        end
    end

    if sCount >= ddActThres # if active synapses exceed the spike threshold
        return true # the dendrite spikes
    else
        return false
    end
end


function proximalSpike(dendrite::PDendrite, inpSpace)
#= Returns true if proximal dendrite spikes due to FF input =#

    synCnctdThres::Float16 = 0.4
    spike::Bool = false

    for syn in dendrite.synapses
        if inpSpace[syn.nrn] == true && syn.perm > synCnctdThres
            spike = true
        end
    end

    return spike
end
