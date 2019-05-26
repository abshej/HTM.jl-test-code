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

 
function distal!(minicol::Minicol, cmpMatrix)
    for nrn in eachindex(minicol.neurons)
        distal!(minicol.neurons[nrn], cmpMatrix)
    end
end
