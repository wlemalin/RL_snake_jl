module TrainDat

include("HyperParameters.jl")
using .HyperParameters: FILENAME

using CSV
using DataFrames

export add_data

const FILE = joinpath(["visualisation/data",FILENAME]) * ".csv"

function add_data(snake_length::Vector{Int}, steps::Vector{Int}, total_reward::Vector{Float64}; folder="visualisation/data")
    mkpath(folder)

    file = 
    if isfile(FILE)
        data = CSV.read(FILE, DataFrame)       
        last_episode = data[!, :episode][end]
    else
        data = DataFrame(episode=Int[], snake_length=Int[], steps=Int[], total_reward=Int[])
        last_episode = 0
    end

    new_episodes = last_episode .+ (1:length(snake_length))
    new_row = DataFrame(episode=new_episodes, snake_length=snake_length, steps=steps, total_reward=total_reward)
    append!(data, new_row)

    CSV.write(FILE, data)
    
    println("Added $(length(snake_length)) episodes to $FILE")
end

end
