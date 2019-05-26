struct Params
    def_syn_perm::Int8
    syn_thres::Int8
    syn_inc::Int8
    syn_dec::Int8
    sparsity::Int
end


mutable struct SpatialPooler
    dims::Tuple{Int, Int}
    proximal::Matrix{SparseVector}
    params::Params
end


function createSP(noOfMinicols::Int, noOfNeuronsPerMinicol::Int)
    params = []
    for i in fieldnames(Params)
        println(i, " : ")
        push!(params, parse(Int, readline()))
    end
    
    SpatialPooler(tuple(noOfMinicols, noOfNeuronsPerMinicol), Matrix{SparseVector}(noOfMinicols, noOfNeuronsPerMinicol), Params(params...))
end


function randProximalConnections!(sp::SpatialPooler, inputLength::Int, noOfConnectionsPerNeuron::Int = 1)
    potentialIndices = collect(1:inputLength)
    potentialIndicesCopy = copy(potentialIndices)

    for i in eachindex(sp.proximal)
        sp.proximal[i] = SparseVector(zeros(Int8, inputLength))
    end

    for n in 1:noOfConnectionsPerNeuron
        for i in eachindex(sp.proximal)
            randIndex = rand(potentialIndicesCopy)
            sp.proximal[i][randIndex] = rand(35:55)
            splice!(potentialIndicesCopy, findin(potentialIndicesCopy, randIndex)[1])
            if potentialIndicesCopy == []
                potentialIndicesCopy = copy(potentialIndices)
            end
        end
    end

end


function randProximalStaticConnections!(sp::SpatialPooler, inputLength::Int, noOfConnectionsPerNeuron::Int = 1)
    potentialIndices = collect(1:inputLength)
    potentialIndicesCopy = copy(potentialIndices)

    for i in eachindex(sp.proximal)
        sp.proximal[i] = SparseVector(zeros(Int8, inputLength))
    end

    for n in 1:noOfConnectionsPerNeuron
        for i in eachindex(sp.proximal)
            randIndex = rand(potentialIndicesCopy)
            sp.proximal[i][randIndex] = 100
            splice!(potentialIndicesCopy, findin(potentialIndicesCopy, randIndex)[1])
            if potentialIndicesCopy == []
                potentialIndicesCopy = copy(potentialIndices)
            end
        end
    end

end


function proximalActivation!(sp::SpatialPooler, input::Union{BitArray, Array{Bool}})
    #Activation with synaptic learning
    activationMatrix = falses(sp.dims...)

    for m in 1:sp.dims[1], n in 1:sp.dims[2]
        for synapse in sp.proximal[m, n].nzind
            if input[synapse] == true && sp.proximal[m, n][synapse] >= sp.params.syn_thres
                activationMatrix[m, n] = true
                if sp.proximal[m, n][synapse] <= 100 - sp.params.syn_inc
                    sp.proximal[m, n][synapse] += sp.params.syn_inc
                else
                    sp.proximal[m, n][synapse] = 100
                end
            elseif input[synapse] == true && sp.proximal[m, n][synapse] < sp.params.syn_thres
                sp.proximal[m, n][synapse] += sp.params.syn_inc
            else
                if sp.proximal[m, n][synapse] >= sp.params.syn_dec
                    sp.proximal[m, n][synapse] -= sp.params.syn_dec
                else
                    sp.proximal[m, n][synapse] = 0
                end
            end
        end
    end

    return activationMatrix
end


function proximalActivation(sp::SpatialPooler, input::Union{BitArray, Array{Bool}})
    #Activation without synaptic learning
    activationMatrix = falses(sp.dims...)

    for m in 1:sp.dims[1], n in 1:sp.dims[2]
        for synapse in sp.proximal[m, n].nzind
            if input[synapse] == true && sp.proximal[m, n][synapse] >= sp.params.syn_thres
                activationMatrix[m, n] = true
                break
            end
        end
    end

    return activationMatrix
end


function columnActivationCount(activationMatrix)
    #Overlap scores of minicolumns
    return activationMatrix * ones(Int, (size(activationMatrix)[2], 1))
end


function spGlobalInhibitionActivation!(sp::SpatialPooler, input::Union{BitArray, Array{Bool}})
    #Learning SP
    activatedColumns::Vector{Int} = []
    overlapScores = vec(columnActivationCount(proximalActivation!(sp, input)))

    for i in 1:sp.params.sparsity
        push!(activatedColumns, findin(overlapScores, maximum(overlapScores))[1])
        splice!(overlapScores, activatedColumns[end])
    end

    return activatedColumns
end


function spGlobalInhibitionActivation(sp::SpatialPooler, input::Union{BitArray, Array{Bool}})
    #Non-learning SP
    activatedColumns::Vector{Int}
    overlapScores = vec(columnActivationCount(proximalActivation(sp, input)))

    for i in 1:sp.params.sparsity
        push!(activatedColumns, findin(overlapScores, maximum(overlapScores))[1])
        splice!(overlapScores, activatedColumns[end])
    end

    return activatedColumns
end


function spLocalInhibitionActivation!(sp::SpatialPooler, input::Union{BitArray, Array{Bool}})
    activatedColIndices = zeros(Int, sp.dims[1])
    overlapScores = columnActivationCount(proximalActivation!(sp, input))
    for i in 1:sp.params.sparsity
    end    
    
end


function spLocalInhibitionActivation(sp::SpatialPooler, input::Union{BitArray, Array{Bool}})
    activatedColumns::Vector{Int}
    overlapScores = columnActivationCount(proximalActivation(sp, input))

    
end


function displaySPActivation(activatedColumns::Vector{Int}, dims::Tuple{Int, Int})
    activationMatrix = zeros(Int8, dims)

    for col in activatedColumns
        activationMatrix[col, :] = 1
    end

    return activationMatrix
end
