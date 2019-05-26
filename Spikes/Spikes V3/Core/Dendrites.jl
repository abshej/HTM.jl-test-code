include("Units.jl")

function distalNDMA(den::DEN, layer::LYR)
    synSpikes::Int = 0
    for syn in den.syns
        if layer.mncs[syn.axnID[1]].nrns[syn.axnID[2]].axon == true
            if syn.perm > SYN_PERM_THRES
                synSpikes += 1
            end
        end
    end
    if synSpikes > DD_SYN_THRES
        return true
    else
        return false
    end
end

function proximalNMDA(den::DEN, inpVec::Vector{Bool})
    for syn in den.syns
        if inpVec[syn.axnID[1]] == true
            return true
        end
    end
    return false
end

function proximalNMDA!(den::DEN, inpVec::Vector{Bool})
    nmda::Bool = false
    for syn in eachindex(den.syns)
        if inpVec[den.syns[syn].axnID[1]] == true
            (den.syns[syn].perm < 0.9) && (den.syns[syn].perm += SYN_PERM_INC)
            nmda = true
        else
            (length(den.syns) > 1) && (den.syns[syn].perm -= SYN_PERM_DEC)
        end
    end
    return nmda
end
