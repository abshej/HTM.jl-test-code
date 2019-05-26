include("Structures.jl")
include("Parameters.jl")
include("Creation.jl")

function updateLayer!(layer::Layer, inputSpace::SparseVector, links::AbstractArray )
    #=
    Update the neural activation in a layer based on 
    its connections with input space
    =#

    for i in eachindex(layer.minicolumns)
        for ind in inputSpace.nzind
            matchedIndices = findin(links[i], ind)
            if matchedIndices != []
                for index in matchedIndices
                    layer.minicolumns[i].neurons[index].axon = true
                end
            end
        end
    end
end

function updateLayer!(layer::Layer, inputSpace::AbstractArray, links::AbstractArray)
    #=
    Updates the activation states of neurons in minicolumns of a layer
    depending on the input
    This function takes SparseVector input for the inputSpace
    =#
    
    for minicolInd in eachindex(layer.minicolumns)
	for ind in eachindex(inputSpace)
	    if inputSpace[ind] == 1 || inputSpace[ind] == true
		matchedLinks = findin(reshape(links, length(links))[minicolInd], ind)
		#println(matchedLinks)
		if matchedLinks != []
		    for index in matchedLinks
			layer.minicolumns[minicolInd].neurons[index].axon = true
		    end
		end
	    end
	end
    end
end

function resetLayer!(layer::Layer)
    for miniCol in layer.minicolumns
	for neuron in miniCol.neurons
	    neuron.axon = false
	end
    end
end

function getIterableLayerActivation(layer::Layer)
    #=
    Update the neural activation in a layer based on 
    its connections with input space
    Use saved layer state to grow connections
    =#
    
    columnActivation::AbstractArray{Int, 1} = []
    for i in layer.minicolumns
        count::Int = 0
        for j in i.neurons
            if j.axon == true
                count += 1
            end
        end
        push!(columnActivation, count)
    end
    return columnActivation
end

function spatialPooling!(layer::Layer) 

    columnActivation = getIterableLayerActivation(layer)
    sort!(columnActivation, rev=true)
    activeMinicolumnCount::Int = 0
    activeColumns::AbstractArray{Int} = []
    inactiveColumns::AbstractArray{Int} = []
    
    for i in eachindex(columnActivation)#[1:SparsityCount.value]
        for j in eachindex(layer.minicolumns)
            if getMinicolumnActivity(layer.minicolumns[j]) == columnActivation[i]
                if activeMinicolumnCount <= SparsityCount.value
                    for neuron in layer.minicolumns[j].neurons
                        neuron.axon = true
                    end
                    
                    push!(activeColumns, j)
                    activeMinicolumnCount += 1
                else
                    push!(inactiveColumns, j)
                end
                break
            end
        end
    end

    for i in inactiveColumns
        for j in layer.minicolumns[i].neurons
        j.axon = false
        end
    end
end

