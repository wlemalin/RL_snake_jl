module PlayGame

include("InitGame.jl")

using .InitGame
using  Random

#Exports from HyperParameters.jl
export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT
export APPLE_EATEN, VACANT, HURDLE

#Exports from InitGame
export init_world, init_snake, place_snake!, place_apple!
export update_vision!, update_state!, init_game, StateGame

#Exports from PlayGame
export action_to_direction, step!, print_world, state_to_key, get_q_values, check_haskey!, play_trained_game!, get_time

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
        return true, HURDLE, game.apple_pos  
    end

    apple_eaten = new_head == game.apple_pos
    score = apple_eaten ? APPLE_EATEN : VACANT
    
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

function state_to_key(game::StateGame)
    vision_str = join(game.vision)
    body_str = join(game.body_relative_pos)
    return "$(vision_str)|$(game.apple_relative_pos)" #|$(body_str)
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

function get_time(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, game::StateGame)
    key = state_to_key(game)
    check_haskey!(q_table, key)

    return q_table[key][2]
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

function play_trained_game!(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}; max_steps=200)
    game = init_game()
    total_score = 0

    for step in 1:max_steps
        current_key = state_to_key(game)
        check_haskey!(q_table, current_key)
        action = argmax(q_table[current_key][1])

        game_over, score, ___ = step!(game, action)
        total_score += score

        println("\nStep $step, Action: $action")
        print_world(game)
        println("Score: $total_score")

        if game_over
            println("Game Over! Final score: $total_score")
            break
        end

        sleep(0.3)
    end

    return total_score
end

end