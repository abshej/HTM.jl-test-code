mutable struct Syn
#= SYnapse =#
    col::Int16 # index
    nrn::Int16 # index
    perm::Float16 # synaptic permanence
end

mutable struct DDendrite
#= Distal Dendrite of Neuron =#
    synapses::AbstractArray{Syn, 1}
end


mutable struct PDendrite
#= Proximal Dendrite of Neuron =#
    synapses::AbstractArray{Syn, 1}
end


mutable struct Neuron
#= HTM Neuron =#
    distal::AbstractArray{DDendrite, 1}
    proximal::PDendrite
end


mutable struct Minicol
#= Minicolumn of Neurons =#
    neurons::AbstractArray{Neuron, 1}
end


mutable struct Layer
#= Layer(Array) of Minicolumns (1D) =#

    minicols::AbstractArray{Minicol, 1}
end
