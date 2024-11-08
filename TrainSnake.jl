module TrainSnake

include("Qtable.jl")
include("TrainDat.jl")
include("PlayGame.jl")

using .PlayGame
using .Qtable
using .TrainDat

using Random
using Statistics

#Exports from HyperParameters.jl
export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT
export APPLE_EATEN, VACANT, HURDLE
export INVERSE, CONST_STEP_SIZE

#Exports from InitGame
export init_world, init_snake, place_snake!, place_apple!
export update_vision!, update_state!, init_game, StateGame

#Exports from PlayGame
export action_to_direction, step!, print_world, state_to_key, get_q_values, check_haskey!, play_trained_game!, get_time

#Exports from TrainSnake
export update_q_table!, egreedy, train_q_learning

#Exports from Qtable
export save_q_table, load_q_table

#Exports from TrainDat
export add_data

#Exports from Symmetry
export rotate90_clockwise, diag_symmetry_y_eq_x, rotations, transform_apple_position
export transform_indices, symmetries, run_transformations, apply_inverse_transform
export all_transformations_with_indices_and_apple, canonical_form_with_indices_and_apple, inverse_transformations

function update_q_table!(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, 
    current_key, action::Int, reward::Any, next_key)

    check_haskey!(q_table, current_key)
    check_haskey!(q_table, next_key)

    current_q = q_table[current_key][1][action]
    next_max_q = maximum(q_table[next_key][1])

    if reward == HURDLE && KICK_HURDLE
        q_table[current_key][1][action] = - abs(HURDLE * 10)
    else
        q_table[current_key][1][action] = CONST_STEP_SIZE ? 
            (current_q + ALPHA * (reward + GAMMA * next_max_q - current_q)) :
            (current_q + (1 / (q_table[current_key][2][action] + 1)) * (reward + GAMMA * next_max_q - current_q))
    end

    q_table[current_key][2][action] += 1
end

function check_hurdle(q_values::Vector{Float64})
    accepted_indice = findall(x -> x > HURDLE, q_values)
    if isempty(accepted_indice)
        return rand(1:4)
    else
        return rand(accepted_indice)
    end 
end

function egreedy(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, current_key::String, inverse_transform::String)
    check_haskey!(q_table, current_key)
    q_values = q_table[current_key][1]

    if rand() < EPSILON 
        canonical_action = KICK_HURDLE ? check_hurdle(q_values) : rand(1:4)
    else
        canonical_action = argmax(q_values)
    end

    if INVERSE == true
        action = apply_inverse_transform(inverse_transform, canonical_action)
        return action, canonical_action
    end

    return canonical_action, canonical_action
end

# function upper_confident_bound(q_table::Dict{String, Tuple{Vector{Float64}, Vector{Int}}}, game::StateGame)
#     q_values, inverse_transform = get_q_values(q_table, game)
#     time_values = get_time(q_table, game)
#     t_sum = sum(time_values)
#     canonical_action = argmax(q_values .+ ALPHA * sqrt.(log.(t_sum + 1) ./ (time_values .+ 1)))
#     action = apply_inverse_transform(inverse_transform, canonical_action)
#     return action, canonical_action
# end

function train_q_learning(episodes::Int; max_steps=500)

    q_table = load_q_table()
    
    episode_rewards = zeros(episodes)
    episode_steps = zeros(Int, episodes)
    episode_lengths = zeros(Int, episodes)

    for episode in 1:episodes
        game = init_game()
        total_reward = 0
        steps = 0
        current_key, inverse_transform = state_to_key(game)

        for step in 1:max_steps
            action, canonical_action = egreedy(q_table, current_key, inverse_transform)
            #action = upper_confident_bound(q_table, game)           
            
            game_over, reward, new_apple_pos = step!(game, action)
            apple_pos = new_apple_pos

            next_key, inverse_transform = state_to_key(game)

            q_reward = reward

            if game_over
                q_reward = HURDLE
            end

            update_q_table!(q_table, current_key, canonical_action, q_reward, next_key)

            current_key = next_key

            total_reward += reward
            steps += 1

            if game_over
                break
            end

        end

        episode_rewards[episode] = total_reward
        episode_steps[episode] = steps
        episode_lengths[episode] = game.length
        

        if episode % 50000 == 0
            println("Episode $episode: Reward = $total_reward, Steps = $steps")
            save_q_table(q_table)
        end
    end

    save_q_table(q_table)
    add_data(episode_lengths, episode_steps, episode_rewards)
    
end

end