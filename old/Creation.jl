include("Structures.jl")
include("Parameters.jl")

function addSynapseToSegment!(postSynapticSegment, preSynapticNeuron; initialPermanence=DefaultPerm)
    #=
    Adds a synapse on a segment from the postSynaptic neuron which connects to the preSynapticNeuron's axon
    =#
    #newSynapse = Synapse(preSynapticNeuron, initialPermanence)
    push!(postSynapticSegment.synapses, Synapse(preSynapticNeuron, initialPermanence))
end

function addSegmentToNeuron!(parentNeuron; segmentType="dd")
    #=
    Grow a segment on a neuron
    segmentType:
    dd -> DistalDendrite
    ad -> ApicalDendrite
    =#
    if lowercase(strip(segmentType)) == "dd"
	#newDendrite = DistalDendrite([])
	push!(parentNeuron, DistalDendrite([]))
    elseif lowercase(strip(segmentType)) == "ad"
	#newDendrite = ApicalDendrite([])
	push!(parentNeuron, ApicalDendrite([]))
    else
	error("""Undefined type \"$(segmentType)\" for a dendrite""")
    end
end

function getActiveSegmentsOnNeuron(neuron::Neuron)
    #=
    Gives the list of active dendrites on a neuron after thresholding
    =#

    # For Distal Dendrites
    activeDistalDendrites = Nullable{AbstractArray}()
    for segment in Neuron.distalSegments
        if getActiveSynapsesOnSegment(segment) > MinActiveDistalSynapses
            push!(activeDendrites, segment)
        end
    end

    # For Apical Dendrites
    activeApicalDendrites = Nullable{AbstractArray}()
    for segment in Neuron.apicalSegments
        if getActiveSynapsesOnSegment(segment) > MinActiveApicalSynapses
            push!(activeApicalDendrites, segment)
        end
    end
    
    activeDistalDendrites, activeApicalDendrites
end

function getActiveSynapsesOnSegment(segment::Dendrite)
    #=
    Gives the number of active synapses on a single segment
    =#
    synapticActivationCount::Int = 0
    for synapse in segment.synapses
        if synapse.presynapticNeuron.axon && (synapse.permanence > Params.ConnectedPerm)
            synapticActivationCount += 1
        end
    end
    synapticActivationCount
end

function getMinicolumnActivity(minicolumn::Minicolumn)
    #=
    Gives the number of active neurons in a single minicolumn
    =#
    activeNeurons::Int = 0
    for neuron in minicolumn.neurons
        if neuron.axon == true
            activeNeurons += 1
        end
    end
    activeNeurons
end

function getLayerActivity(layer::Layer)
    #=
    Returns total number of active neurons in any layer
    =#
    
    count::Int = 0
    for i in layer.minicolumns
        count += getMinicolumnActivity(i)
    end
    return count
end

function createMinicolumn(;N::Int=NeuronsPerMinicolumn.value)
    #=
    Create a minicolumn with no. of neurons = NeuronsPerMinicolumn
    =#
    
    neurons::AbstractArray{Neuron, 1} = []
    for i = 1:N
        push!(neurons, Neuron([],[],false))
    end
    Minicolumn('i', neurons)
end

function createLayer(;dimension::Int=DefaultLayerDim, width::Int=WidthOfLayer.value, breadth::Int=BreadthOfLayer.value)
    #=
    Create a layer of minicolumns using NoOfMinicolumns
    =#
    layer::AbstractArray{Minicolumn} = []
    if width==WidthOfLayer.value && breadth==BreadthOfLayer.value
        maxColumns = NoOfMinicolumns.value
    else
        maxColumns = width*breadth
    end

    # Create 1D layer of minicolumns
    for i in 1:maxColumns
        push!(layer, createMinicolumn())
    end
    
    if dimension == 1
        return Layer(layer)
    # Create 2D layer of minicolumns
    else dimension == 2    
        return Layer(reshape(layer, width, breadth))
    end
end

function getPredictiveMinicolumns(layer::Layer)
    predictiveMinicolumns::AbstractArray = []
    predictiveNeuronsMinicolumns::AbstractArray = []
    for i in eachindex(layer.minicolumns)
        if layer.minicolumns[i].state == 'p'
            push!(predictiveMinicolumns, i)
        elseif layer.minicolumns[i].state == 't'
            push!(predictiveNeuronsMinicolumns, i)
        end
    end
    return (predictiveMinicolumns, predictiveNeuronsMinicolumns)
end

function connectMinicolumn(minicolumn::Minicolumn, inpWidth::Int, inpBreadth::Int)
    totalNeurons::Int16 = length(minicolumn.neurons)
    connectedIndices::Set = Set()
    for i in eachindex(minicolumn.neurons)
        while <=(connectedIndices, length(minicolumn.neurons))
        end
    end
end

