include("Units.jl")
include("Neurons.jl")


function totalSyns(minicol::Minicol)
    count::Int = 0
    for nrn in minicol.neurons
        count += totalSyns(nrn)
    end
    return count
end

function totalNeurons(minicol::Minicol)
    return length(minicol.neurons)
end


function minicol(noOf::Int)
    Minicol([Neuron([],PDendrite([])) for i in 1:noOf])
end


function proximalOut(minicol::Minicol, inpSDR)    
    ffActivation::BitArray = []
    for neuron in minicol.neurons
        push!(ffActivation, proximalOut(neuron, inpSDR))
    end
    return ffActivation
end


function predictions(minicol::Minicol, outSDR)    
    predictive::BitArray = []
    for neuron in minicol.neurons
        push!(predictive, isPredictive(neuron, outSDR))
    end
    return predictive
end

 
function distal!(minicol::Minicol, colOutSDR, cmpMatrix, colID::Int)
    cmpMat = cmpMatrix
    for actnrn in findin(colOutSDR, true)
        distal!(minicol.neurons[actnrn], cmpMat)
    end
end


function distalConnections!(minicol::Minicol, colOutSDR, outSDR, col::Int)
    for actnrn in findin(colOutSDR, true)
        distalConnections!(minicol.neurons[actnrn], outSDR, colOutSDR, col)
    end
end
