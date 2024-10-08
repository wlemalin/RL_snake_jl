module PlayModule

export print_world, state_to_key, get_q_values, play_trained_game!, get_state, choose_action, action_to_direction, step!

include("Constantes.jl")
include("InitialiseModule.jl")
using .Constantes
using ..InitialiseModule: GameState
using ..InitialiseModule: place_apple!


# Get direction vector from action
function action_to_direction(action)
    if action == UP
        return (0, 1)
    elseif action == RIGHT
        return (1, 0)
    elseif action == DOWN
        return (0, -1)
    else  # LEFT
        return (-1, 0)
    end
end

# Move snake and update game state
function step!(world, head_pos, body_positions, apple_pos, action)
    dy, dx = action_to_direction(action)
    new_head = [head_pos[1] + dy, head_pos[2] + dx]
    
    # Check collision with wall or body
    if world[new_head[1], new_head[2]] == WALL || 
       world[new_head[1], new_head[2]] == SNAKE_BODY
        return true, -1, apple_pos  # Game over
    end
    
    # Check if apple is eaten
    apple_eaten = (new_head[1], new_head[2]) == apple_pos
    score = apple_eaten ? 1 : 0
    
    # Update snake positions
    world[head_pos[1], head_pos[2]] = SNAKE_BODY
    pushfirst!(body_positions, copy(head_pos))
    
    if !apple_eaten
        # Remove tail if apple not eaten
        tail = pop!(body_positions)
        world[tail[1], tail[2]] = EMPTY
    end
    
    # Update head
    head_pos[1], head_pos[2] = new_head
    world[head_pos[1], head_pos[2]] = SNAKE_HEAD
    
    # Place new apple if eaten
    if apple_eaten
        apple_pos = place_apple!(world)
    end
    
    return false, score, apple_pos
end
# Choose action using epsilon-greedy policy
function choose_action(q_table::Dict{String, Vector{Float64}}, state::GameState)
    if rand() < EPSILON
        return random_action()
    else
        q_values = get_q_values(q_table, state)
        return argmax(q_values)
    end
end

function random_action()
  return rand(1:4)
end
  # Get the enhanced game state
function get_state(world, head_pos, apple_pos, body_positions)
    # Get vision matrix
    vision = zeros(Int, 2*VIEW_RANGE+1, 2*VIEW_RANGE+1)
    for i in -VIEW_RANGE:VIEW_RANGE
        for j in -VIEW_RANGE:VIEW_RANGE
            y, x = head_pos[1] + i, head_pos[2] + j
            vision[i+VIEW_RANGE+1, j+VIEW_RANGE+1] = world[y, x]
        end
    end
    
    # Calculate relative apple position
    apple_relative_pos = (apple_pos[2] - head_pos[2], head_pos[1] - apple_pos[1])
    
    # Create and return GameState
    return GameState(
        vision,
        apple_relative_pos,
        length(body_positions) + 1  # +1 for the head
    )
end

# Helper function to convert GameState to a string key for our Q-table
function state_to_key(state::GameState)
    # Flatten vision matrix to string and combine with apple position
    vision_str = join(state.vision)
    return "$(vision_str)|$(state.apple_relative_pos)"
end

# Get Q-values for a state
function get_q_values(q_table::Dict{String, Vector{Float64}}, state::GameState)
    key = state_to_key(state)
    if !haskey(q_table, key)
        q_table[key] = zeros(4)
    end
    return q_table[key]
end


# Pretty print the world
function print_world(world)
    symbols = Dict(
        EMPTY => "·",
        WALL => "#",
        APPLE => "🍎",
        SNAKE_BODY => "*",
        SNAKE_HEAD => "🐸"
    )
    
    for i in 1:GRID_SIZE
        for j in 1:GRID_SIZE
            print(symbols[world[i, j]], " ")
        end
        println()
    end
end




# Modify play_game! to use Q-learning
function play_trained_game!(q_table::Dict{String, Vector{Float64}}, 
                           world, head_pos, body_positions, apple_pos; 
                           max_steps=1000)
    total_score = 0
    
    for step in 1:max_steps
        state = get_state(world, head_pos, apple_pos, body_positions)
        action = choose_action(q_table, state)
        
        game_over, score, new_apple_pos = step!(world, head_pos, 
                                                body_positions, apple_pos, action)
        apple_pos = new_apple_pos
        total_score += score
        
        println("\nStep $step, Action: $action")
        print_world(world)
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
