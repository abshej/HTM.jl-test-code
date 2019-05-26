include("Constant.jl")

function twoDIndices(A::SparseMatrixCSC)
    indices::NeuronVector = []
    rows = rowvals(A)
    vals = nonzeros(A)
    n = size(A)[2]
    for i = 1:n
        for j in nzrange(A, i)
            row = rows[j]
            val = vals[j]
            push!(indices, (row, i))
        end
    end
    return indices
end


function compare(A::Bool, B::Bool)
    if A == true
        return 1
    elseif A == false && B == true
        return -1
    else
        return 0
    end
end


function proxActn!(layer::Layer, inp::BitRepresentation)
    actstates = sparse(falses(layer.dims[1], layer.dims[2]))
    
    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        for i in layer.proximal[m, n].nzind
            if inp[i] == true && layer.proximal[m, n][i] >= layer.params.syn_thres
                actstates[m, n] = true
                layer.proximal[m, n][i] += layer.params.syn_inc
                if layer.proximal[m, n][i] > 100
                    layer.proximal[m, n][i] = 100
                end
            elseif inp[i] == true && layer.proximal[m, n][i] < layer.params.syn_thres
                layer.proximal[m, n][i] += layer.params.syn_inc
            else
                layer.proximal[m, n][i] -= layer.params.syn_dec
                if layer.proximal[m, n][i] < 0
                    layer.proximal[m, n][i] = 0
                end
            end
        end
    end
    
    return actstates
end


function distActn(layer::Layer, activation::SparseMatrixCSC)
    predstates = sparse(falses(layer.dims[1], layer.dims[2]))

    for m in 1:layer.dims[1], n in 1:layer.dims[2]
        for d in eachindex(layer.distal[m, n])
            count::Int = 0
            
            for i in twoDIndices(activation)
                if (m, n) != i
                    if layer.distal[m,n][d][i...] >= layer.params.syn_thres
                        count += 1
                    end
                end
            end
            
            if count >= layer.params.den_syn_thres
                predstates[m, n] = true
            end
        end
    end
    
    return predstates
end


function distSynsDec!(list::NeuronVector, neuron, dec)
    for n in list
        for d in eachindex(neuron)
            if neuron[d][n...] >= dec
                neuron[i][d][n...] -= dec
            else
                neuron[i][d][n...] = 0
            end
        end
    end
end


function distSynsInc!(list::NeuronVector, neuron, inc, def)
    upper = 100 - inc
    for n in list
        for d in eachindex(neuron)
            if 0 < neuron[d][n...] <= upper
                neuron[d][n...] += inc
            elseif neuron[d][n...] > 0
                neuron[d][n...] = 100
            else
                if d == length(neuron)
                    neuron[d][n...] = def
                end
            end
        end
    end
end


function distSyns!(layer::Layer, currentStates::SparseMatrixCSC, previousStates::SparseMatrixCSC, predictions::SparseMatrixCSC)

    list = twoDIndices(previousStates)
    comparation = compare.(currentStates, predictions)
    upper1 = 100 - layer.params.syn_inc
    
    for i in findin(comparation, (1,-1))
        if comparation[i] == -1
            distSynsDec!(list, layer.distal[i], layer.params.syn_dec)
        else
            distSynsInc!(list, layer.distal[i], layer.params.syn_inc, layer.params.def_syn_perm)
        end
    end

end


function mcolActnStatus(activeStates::SparseMatrixCSC, minicols::Int)
    cols::Vector{Int} = zeros(Int, minicols)
    
    for act in twoDIndices(activeStates)
        cols[act[1]] += 1
    end
    return cols
end
