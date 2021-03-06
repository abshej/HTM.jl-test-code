include("Units.jl")
include("Neurons.jl")


function minicolUnits(minicol::Minicol)
    return length(minicol.neurons)
end


function minicol(noOf::Int)
#= Create minicolumn with noOf number of neurons =#
    
    Minicol([Neuron([],PDendrite([])) for i in 1:noOf])
end


function computeMinicolFF(minicol::Minicol, inputSpace)
#= Returns array of neuron outputs depending on their FF inputs =#
    
    ffActivation::BitArray = []

    for neuron in minicol.neurons
        push!(ffActivation, computeNeuronFF(neuron, inputSpace))
    end

    return ffActivation
end


function predictions(minicol::Minicol, preState) #preState is FF output for previous timestep
#= Returns array of predictive states of neurons depending on their distal dendrites=#
    
    predictive::BitArray = []

    for neuron in minicol.neurons
        push!(predictive, predictions(neuron, preState))
    end

    return predictive
end


function distalConnections!(minicol::Minicol, preState, latState)
#= Grows distal synpases on all neurons in minicol depending on prior activation =#

    for nrn in eachindex(minicol.neurons)
        if latState[nrn] == true # if nrn is active at in the latest state
            distalConnections!(minicol.neurons[nrn], preState, latState) # grow distal connections with neurons active during the prior state
        end
    end

end

function randNeuron(len::Int)

    rand(1:len)
end
