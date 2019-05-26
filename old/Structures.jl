abstract type HTM end

mutable struct Synapse{T<:HTM} <:HTM
    #=
    Synapse standard definition
    =#
    presynapticNeuron::T
    permanence::Float16
end

# abstract type to encapsulate types of dendrites
abstract type Dendrite end

mutable struct DistalDendrite <: Dendrite
    #=
    Distal Dendrite standard definition
    =#
    
    synapses::AbstractArray{Synapse, 1}
    #parentNeuronID::Neuron
end

mutable struct ApicalDendrite <: Dendrite
    #=
    Apical Dendrite standard definition
    =#
    
    synapses::AbstractArray{Synapse, 1}
end

mutable struct Neuron <: HTM
    #=
    Neuron standard definition
    =#
    
    distalSegments::AbstractArray{DistalDendrite, 1}
    apicalSegments::AbstractArray{ApicalDendrite, 1}
    axon::Bool # it will only carry the binary activation states(active, inactive)
end

mutable struct Minicolumn
    #=
    Minicolumn standard definition
    =#
    state::Char
    #=
    'i' -> inactive
    'a' -> active
    'p' -> predictive in case of Spatial Pooler
    't' -> some cells in column are predictive in case of Temporal Memory
    =#
    neurons::AbstractArray{Neuron, 1}
end

mutable struct Layer
    #=
    Layer standard definition
    =#

    minicolumns::AbstractArray{Minicolumn}
end
