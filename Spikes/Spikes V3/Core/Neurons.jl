include("Dendrites.jl")

function actionPotential!(nrn::NRN, inpVec::Vector{Bool})
    for pden in nrn.proximal
        if proximalNMDA!(pden, inpVec) == true
            nrn.axon = true
            break
        end
    end
end

function depolarize!(nrn::NRN, layer::LYR)
    for dden in nrn.distal
        synSpikes::Int = 0
        for syn in dden.syns
            if layer.mncs[syn.axnID[1]].nrns[syn.axnID[2]].axon == true
                if syn.perm > SYN_PERM_THRES
                    synSpikes += 1
                end
            end
        end
        if synSpikes > DD_SYN_THRES
            nrn.depol =  true
            break
        end
    end
end

function semiRest!(nrn::NRN)
    nrn.axon = false
end

function locateSyn(nrn::NRN, id::Tuple)
    synID = Nullable{Tuple}()
    for i in eachindex(nrn.distal)
        for j in eachindex(nrn.distal[i].syns)
            if nrn.distal[i].syns[j].axnID == id
                synID = (i,j)
                return synID
            end
        end
    end
    return synID
end

function gds!(nrn::NRN, actNeurons::Vector{Tuple})
    for id in actNeurons
        if filter(x -> x.axnID==id, nrn.distal[end].syns) == []
            push!(nrn.distal[end].syns, SYN(id, Float16(DEF_SYN_PERM)))
        end
    end
    
end

function gdsinc!(nrn::NRN, actNeurons::Vector{Tuple})
    for id in actNeurons
        for i in filter(x -> x.axnID==ID, nrn.distal[end].syns)
            x.perm += Float16(SYN_PERM_INC)
        end
    end
end

function gdsdec!(nrn::NRN, actNeurons::Vector{Tuple})
    for id in actNeurons
        for i in filter(x -> x.axnID==ID, nrn.distal[end].syns)
            x.perm -= Float16(SYN_PERM_DEC)
        end
    end
end

function rest!(nrn::NRN)
    nrn.axon = false
    nrn.depol = false
end

function depolRest!(nrn::NRN)
    nrn.depol = false
end

function overlapScore(nrn::NRN, inpVec::Vector{Bool})
    score::Int = 0
    for pden in nrn.proximal
        for syn in pden.syns
            if inpVec[syn.axnID[1]] == true
                score += 1
            end
        end
    end
    return score
end

