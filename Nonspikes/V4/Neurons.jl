include("Units.jl")
include("Params.jl")
include("Dendrites.jl")

function totalSyns(neuron::Neuron)
    count::Int = 0
    for dd in neuron.distal
        count += totalSyns(dd)
    end
    return count
end


function totalDendrites(neuron::Neuron)
    length(neuron.distal)
end


function findSyn(neuron::Neuron, nrnID::Tuple{Int, Int})
    ddInd = Nullable{Tuple{Int, Int}}()
    for dd in eachindex(neuron.distal)
        synInd::Int = findSyn(neuron.distal[dd], nrnID)
        if isnull(synInd) == false
            ddInd = (dd, synInd)
            break
        end
    end
    return status
end
        

function proximalOut(neuron::Neuron, inpSDR)
    return isSpike(neuron.proximal, inpSDR)
end


function isPredictive(neuron::Neuron, outSDR)
    status::Bool = false
    for dd in neuron.distal
        if isSpike(dd, outSDR) == true
            status = true
            break
        end
    end
    return status
end


function synPermInc!(neuron::Neuron, cmpMatrix)    
    for col in eachindex(cmpMatrix)
        for crtPred in findin(cmpMatrix[col], 1)
            synInd = findSyn(neuron, (col, crtPred))
            if isnull(synInd) == false
                synPermInc!(neuron.distal[synInd[1]].synapses[synInd[2]])
            end
        end
    end
end


function synPermDec!(neuron::Neuron, cmpMatrix)
    for col in eachindex(cmpMatrix)
        for wrngPred in findin(cmpMatrix[col], -1)
            synInd = findSyn(neuron, (col, wrngPred))
            if isnull(synInd) == false
                synPermDec!(neuron.distal[synInd[1]].synapses[synInd[2]])
                if neuron.distal[synInd[1]].synapses[synInd[2]].perm <= 0.0
                    splice!(neuron.distal[synInd[1]].synapses, synInd[2])
                end
            end
        end
    end
end

function synNew!(neuron::Neuron, cmpMatrix)

    for col in eachindex(cmpMatrix)
        for newnrn in findin(cmpMatrix[col], 2)
            if totalSyns(neuron.distal[end]) > MAX_DISTAL_SYNS
                distalDendrite!(neuron)
            end
            syn!(neuron.distal[end], (col, newnrn))
        end
    end
end

function distal!(neuron::Neuron, cmpMatrix)
    if totalDendrites(neuron) == 0
        distalDendrite!(neuron)
    end
    
    synPermInc!(neuron, cmpMatrix)
    synPermDec!(neuron, cmpMatrix)
    synNew!(neuron, cmpMatrix)
end

