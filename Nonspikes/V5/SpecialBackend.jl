function compareUnit1(prediction, output)
    if prediction == true && output == true # increment
        return 1
    elseif prediction == true && output == false # decrement 
        return -1
    elseif prediction == false && output == true # new 
        return 2
    elseif prediction == false && output == false
        return 0
    end
end

function compareUnit2(outSDR, cmpMat)
    if outSDR == true && cmpMat == 2
        return 2
    elseif outSDR == true && cmpMat == 1
        return 1
    elseif outSDR == true && cmpMat == -1
        return -1
    elseif outSDR == true && cmpMat == 0
        return 2
    else
        return 0
    end
end


function compareMatrix1(predictions, outSDR)
    cmpMatrix::AbstractArray = []
    for col in eachindex(predictions)
        push!(cmpMatrix, compareUnit1.(predictions[col], outSDR[col]))
    end
    return cmpMatrix
end

function compareMatrix2(outSDR, cmpMat)
    cmpMatrix::AbstractArray = []
    for col in eachindex(outSDR)
        push!(cmpMatrix, compareUnit2.(outSDR[col], cmpMat[col]))
    end
    return cmpMatrix
end
