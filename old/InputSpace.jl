include("Structures.jl")
include("Parameters.jl")

function convertToSparse(inputSpace::BitArray)
    #=
    Returns SparseVector
    =#
    sparsevec(inputSpace)
end

function getRandomLinks(inputDimensions::Tuple, layerDimensions::Tuple, N::Int=NeuronsPerMinicolumn.value; topology::Bool=TopographicMaps)
    #=
    New Version of above above function
    =#
    
    layercentricMap::AbstractArray = []
    noOfInputBits = prod(inputDimensions)
    noOfLayerUnits = prod(inputDimensions)
    
    if length(layerDimensions) > 1
        for i in 1:layerDimensions[1]
            for j in 1:layerDimensions[2]
                push!(layercentricMap, [[rand(1:inputDimensions[1]), rand(1:inputDimensions[2])] for k = 1:N])
            end
        end
        layercentricMap = reshape(layercentricMap, layerDimensions[1], layerDimensions[2])
    elseif length(layerDimensions) == 1
        layercentricMap = Matrix{Int}(layerDimensions[1], N)
        rand!(layercentricMap, 1:inputDimensions[1])
    end
        
    return layercentricMap
end
