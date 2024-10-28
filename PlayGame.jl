module PlayGame

include("HyperParameters.jl")
# include("InitGame.jl")

using .HyperParameters
using ..InitGame

export action_to_direction, step!, print_world, state_to_key, get_q_values, check_haskey!

function action_to_direction(action)
    if action == UP
        return CartesianIndex(-1, 0)
    elseif action == RIGHT
        return CartesianIndex(0, 1)
    elseif action == DOWN
        return CartesianIndex(1, 0)
    else  
        return CartesianIndex(0, -1)
    end
end

function step!(game::StateGame, action)
    movement = action_to_direction(action)
    
    new_head = game.head_pos + movement
    
    if game.world[new_head] == WALL || game.world[new_head] == SNAKE_BODY
        return true, -1, game.apple_pos  
    end

    apple_eaten = new_head == game.apple_pos
    score = apple_eaten ? 1 : 0
    
    game.world[game.head_pos] = SNAKE_BODY
    
    pushfirst!(game.body_positions, game.head_pos)
    
    if !apple_eaten
        tail = pop!(game.body_positions)
        game.world[tail] = EMPTY  
    end

    game.head_pos = new_head
    game.world[new_head] = SNAKE_HEAD

    if apple_eaten
        place_apple!(game.world)
    end

    update_state!(game)

    return false, score, game.apple_pos
end

export state_to_key, get_q_values

function state_to_key(game::StateGame)
    vision_str = join(game.vision)
    return "$(vision_str)|$(Tuple(game.apple_relative_pos))"
end

function check_haskey!(q_table, current_key)
    if !haskey(q_table, current_key)
        q_table[current_key] = (zeros(Float64, 4), zeros(Int, 4))  
    end
end

function get_q_values(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, game::StateGame)
    key = state_to_key(game)
    check_haskey!(q_table, key)

    return q_table[key][1]
end

function print_world(game::StateGame)
    symbols = Dict(
        EMPTY => "·",
        WALL => "#",
        APPLE => "🍎",
        SNAKE_BODY => "*",
        SNAKE_HEAD => "🐸"
    )
    
    for i in 1:GRID_SIZE
        for j in 1:GRID_SIZE
            print(symbols[game.world[i, j]], " ")
        end
        println()
    end
end

end