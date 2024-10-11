module PlayModule

export print_world, state_to_key, get_q_values, play_trained_game!, get_state, choose_action, action_to_direction, step!

include("Constantes.jl")
include("InitialiseModule.jl")
using .Constantes
using ..InitialiseModule: GameState
using ..InitialiseModule: place_apple!


"""
Get direction vector from actions variables.
"""
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

function random_action()
    return rand(1:4)
  end

"""
Move snake and update the game state.

This function performs a single step in the Snake game, updating the snake's position, checking for collisions, 
and determining whether an apple is eaten. It also updates the world grid to reflect the changes.

Args:
    world (Array): A 2D array representing the game grid where the snake moves. 
                   It contains values that denote empty cells, snake body, walls, apples, etc.
    head_pos (Array): A two-element array [row, col] representing the current position of the snake's head.
    body_positions (Vector{Array}): A vector of arrays where each array represents the positions 
                                    of the snake's body segments. The head is not included here.
    apple_pos (Tuple{Int, Int}): The current position of the apple in the game grid as a tuple (row, col).
    action (Symbol): The action taken by the snake, which determines the direction the snake will move.
                     It is typically a symbol representing one of the four possible directions (e.g., :up, :down).

Returns:
    Tuple:
        - game_over (Bool): A boolean indicating whether the game is over (true) or not (false). 
                            The game is over if the snake collides with the wall or its own body.
        - score (Int): The current score after the move. The score increases by 1 if the snake eats an apple.
                       If the game ends due to collision, the score is returned as -1.
        - new_apple_pos (Tuple{Int, Int}): The updated position of the apple. If the snake eats the apple, 
                                           a new apple position is generated using `place_apple!`. 
                                           If no apple is eaten, it returns the current position.

The function proceeds as follows:
1. The snake's head is moved in the direction specified by the `action`.
2. It checks if the new head position causes a collision with the wall or its own body, in which case the game ends.
3. If the snake eats the apple, its score increases, and a new apple is placed in the world.
4. The world grid is updated to reflect the snake's new position and whether the tail should be shortened or not.
"""
function step!(world, head_pos, body_positions, apple_pos, action)
    dy, dx = action_to_direction(action)
    new_head = [head_pos[1] + dy, head_pos[2] + dx]
    
    if world[new_head[1], new_head[2]] == WALL || 
       world[new_head[1], new_head[2]] == SNAKE_BODY
        return true, -1, apple_pos  # Game over
    end

    apple_eaten = (new_head[1], new_head[2]) == apple_pos
    score = apple_eaten ? 1 : 0
    
    world[head_pos[1], head_pos[2]] = SNAKE_BODY
    pushfirst!(body_positions, copy(head_pos))
    
    if !apple_eaten
        tail = pop!(body_positions)
        world[tail[1], tail[2]] = EMPTY
    end

    head_pos[1], head_pos[2] = new_head
    world[head_pos[1], head_pos[2]] = SNAKE_HEAD
    
    if apple_eaten
        apple_pos = place_apple!(world)
    end
    
    return false, score, apple_pos
end

# Choose action using epsilon-greedy policy
"""
Choose an action using an epsilon-greedy policy.

This function decides the next action based on the epsilon-greedy policy: 
with probability `EPSILON`, it selects a random action (exploration), 
and with the remaining probability, it selects the action with the highest Q-value (exploitation).

Args:
    q_table (Dict{String, Vector{Float64}}): A Q-table where the key is the state (as a string) and the value 
                                             is a vector of Q-values for each action.
    state (GameState): The current state of the game, represented as a `GameState` object.

Returns:
    action (Int): The index of the chosen action, either randomly chosen or based on the highest Q-value.
"""
function choose_action(q_table::Dict{String, Vector{Float64}}, state::GameState)
    if rand() < EPSILON
        return random_action()
    else
        q_values = get_q_values(q_table, state)
        return argmax(q_values)
    end
end

# Get the enhanced game state
"""
Get the current game state including vision around the snake and relative apple position.

This function computes a state object based on the snake's current surroundings (vision matrix), 
the relative position of the apple, and the length of the snake. The vision matrix is centered around 
the snake's head and extends `VIEW_RANGE` cells in all directions.

Args:
    world (Array): The 2D grid representing the game world.
    head_pos (Array): The current position of the snake's head as [row, col].
    apple_pos (Tuple{Int, Int}): The position of the apple as a tuple (row, col).
    body_positions (Vector{Array}): A vector of arrays representing the positions of the snake's body segments.

Returns:
    GameState: A `GameState` object containing the vision matrix, relative apple position, and snake length.
"""
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
"""
Convert the game state into a string key for indexing the Q-table.

This function flattens the vision matrix and combines it with the relative position of the apple 
to create a unique string key. This string key is used to store and retrieve Q-values in the Q-table.

Args:
    state (GameState): The current game state represented as a `GameState` object.

Returns:
    key (String): A string representation of the game state, used as a key in the Q-table.
"""
function state_to_key(state::GameState)
    # Flatten vision matrix to string and combine with apple position
    vision_str = join(state.vision)
    return "$(vision_str)|$(state.apple_relative_pos)"
end

# Get Q-values for a state
"""
Retrieve the Q-values for a given state from the Q-table.

This function looks up the Q-values corresponding to a given state in the Q-table. 
If the state does not exist in the table, it initializes the Q-values to a zero vector.

Args:
    q_table (Dict{String, Vector{Float64}}): The Q-table mapping state keys to Q-value vectors.
    state (GameState): The current game state represented as a `GameState` object.

Returns:
    q_values (Vector{Float64}): A vector of Q-values for the four possible actions.
"""
function get_q_values(q_table::Dict{String, Vector{Float64}}, state::GameState)
    key = state_to_key(state)
    if !haskey(q_table, key)
        q_table[key] = zeros(4)
    end
    return q_table[key]
end

# Pretty print the world
"""
Print the game world in a human-readable format.

This function prints the game grid where each cell is represented by a symbol. 
It maps game elements like empty cells, walls, apples, snake body, and snake head 
to corresponding visual symbols for easy visualization.

Args:
    world (Array): The 2D array representing the current game world.
"""
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
"""
Play a game using a Q-learning-trained agent.

This function runs a Snake game using a Q-learning agent. It takes in the trained Q-table, 
performs game steps, chooses actions based on the Q-table, updates the game state, 
and prints the world and current score at each step. The game continues until either 
the maximum number of steps is reached or the game ends due to a collision.

Args:
    q_table (Dict{String, Vector{Float64}}): The Q-table containing the learned Q-values.
    world (Array): The 2D array representing the game grid.
    head_pos (Array): The initial position of the snake's head as [row, col].
    body_positions (Vector{Array}): The initial positions of the snake's body segments.
    apple_pos (Tuple{Int, Int}): The initial position of the apple as a tuple (row, col).
    max_steps (Int, optional): The maximum number of steps to run the game, default is 1000.

Returns:
    total_score (Int): The total score obtained by the snake in this game.
"""
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