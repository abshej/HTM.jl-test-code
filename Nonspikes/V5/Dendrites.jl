include("Units.jl")
include("Params.jl")


function totalSyns(dendrite::Union{DDendrite, PDendrite})
    length(dendrite.synapses)
end


function distalDendrite!(neuron::Neuron)
    push!(neuron.distal, DDendrite([]))
end


function isSpike(dendrite::DDendrite, outSDR)
    activeSyns::Int = 0
    for syn in dendrite.synapses
        if outSDR[syn.col][syn.nrn] == true && syn.perm >= SYN_PERM_THRES
            activeSyns += 1
        end
    end
    if activeSyns >= DD_SYN_THRES
        return true 
    else
        return false
    end
end


function isSpike(dendrite::PDendrite, inpSDR)
    spikeStatus::Bool = false
    for syn in dendrite.synapses
        if inpSDR[syn.nrn] == true && syn.perm > SYN_PERM_THRES
            spikeStatus = true
            break
        end
    end
    return spikeStatus
end


function findSyn(dendrite::DDendrite, nrnID::Tuple{Int, Int})
    synInd = Nullable{Int}()
    for syn in eachindex(dendrite.synapses)
        if dendrite.synapses[syn].col == nrnID[1] && dendrite.synapses[syn].nrn == nrnID[2]
            synInd = syn
            break
        end
    end
    return synInd
end


function synPermInc!(syn::Syn)
    syn.perm += SYN_PERM_INCREMENT
end


function synPermDec!(syn::Syn)
    syn.perm -= SYN_PERM_DECREMENT
end


function syn!(dendrite::DDendrite, nrnID::Tuple{Int, Int})
    push!(dendrite.synapses, Syn(nrnID[1], nrnID[2], DEFAULT_SYN_PERM))
end
