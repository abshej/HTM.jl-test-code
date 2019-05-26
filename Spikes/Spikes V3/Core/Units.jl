abstract type HTM end

mutable struct SYN <: HTM
    axnID::Tuple
    perm::Float16
end

mutable struct DEN <: HTM
    syns::Vector{SYN}
end

mutable struct NRN <: HTM
    distal::Vector{DEN}
    proximal::Vector{DEN}
    axon::Bool
    depol::Bool
    #apical::Vector{DEN}
end

mutable struct MNC <: HTM
    nrns::Vector{NRN}
end

mutable struct LYR <: HTM
    mncs::Vector{MNC}
end

#=
abstract type DEN <: HTM

mutable struct DDN <: DEN
    syns::Vector{SYN}
end

mutable struct PDN <: DEN
    syns::Vector{SYN}
end

mutable struct ADN <: DEN
    syns::Vector{SYN}
end
=# 

DD_SYN_THRES = 1

MAX_DD_SYNS = 100

DEF_SYN_PERM = 0.5

SYN_PERM_INC = 0.1000

SYN_PERM_THRES = 0.4000

SYN_PERM_DEC = 0.0500
