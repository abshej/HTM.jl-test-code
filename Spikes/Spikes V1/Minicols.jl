include("Neurons.jl")

function actionPotential!(mnc::MNC, inpVec::Vector{Bool})
    for i in eachindex(mnc.nrns)
        actionPotential!(mnc.nrns[i], inpVec)
    end
end

function depolarize!(mnc::MNC, layer::LYR)
    for i in eachindex(mnc.nrns)
        depolarize!(mnc.nrns[i], layer)
    end
end

function semiRest!(mnc::MNC)
    for i in eachindex(mnc.nrns)
        semiRest!(mnc.nrns[i])
    end
end

function growDistalSyns!(mnc::MNC, activeNeurons::Vector{Tuple})
    for i in eachindex(mnc.nrns)
        growDistalSyns!(mnc.nrns[i], activeNeurons)
    end
end

function rest!(mnc::MNC)
    for i in eachindex(mnc.nrns)
        rest!(mnc.nrns[i])
    end
end
