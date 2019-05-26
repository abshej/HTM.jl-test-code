include("Units.jl")
include("Neurons.jl")


function minicolUnits(minicol::Minicol)
    return length(minicol.neurons)
end


function minicol(noOf::Int)
#= Create minicolumn with noOf number of neurons =#

    neurons::AbstractArray{Neuron, 1} = []

    for i in 1:noOf
        push!(neurons, Neuron([], PDendrite([])))
    end

    #Minicol([Neuron([],PDendrite([])) for i in 1:noOf])
    Minicol(neurons)
end


function proximalAct(minicol::Minicol, inpSpace)
#= Returns array of neuron outputs depending on their FF inputs =#

    ffActivation::BitArray = []

    for neuron in minicol.neurons
        push!(ffActivation, proximalAct(neuron, inpSpace))
    end

    return ffActivation
end


function predictions(minicol::Minicol, preState)
#= Returns array of predictive states of neurons depending on their distal dendrites=#

    predictive::BitArray = []

    for neuron in minicol.neurons
        push!(predictive, isPredictive(neuron, preState))
    end

    return predictive
end


function synIncrement!(minicol::Minicol, colPreState, colLatState, colDiffMat)
#= Increment synapses of neurons in minicol for correct predictions =#

    for nrn in eachindex(minicol.neurons)
        for actnrn in findin(colLatState, true)
            if colDiffMat[actnrn] == 0
                if colPreState[nrn] == true
                    synIncrement!(minicol.neurons[actnrn], (col, actnrn))
                end
            end
        end
    end

end



function synDecrement!(minicol::Minicol, preState, diffMat)
#= Decrement synapses pertaining to falsely predicted neurons for all neurons in minicol =#

    for nrn in eachindex(minicol.neurons)
        for colID in eachindex(diffMat)
            for fNrnID in findin(diffMat[colID], -1)
                if colPreState[nrn] == true
                    synDecrement!(minicol.neurons[nrn], (colID, nrnID))
                end
            end
        end
    end

end


function distalConnections!(minicol::Minicol, preState, mcLatState)
#= Grows distal synpases on all neurons in minicol depending on prior activation =#

    for actnrn in findin(mcLatState, true)
        distalConnections!(minicol.neurons[actnrn], preState)
    end

end
