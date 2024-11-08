module HyperParameters

export EPSILON, ALPHA, GAMMA
export EMPTY, APPLE, WALL, SNAKE_BODY, SNAKE_HEAD, PADDING, GRID_SIZE, VIEW_RANGE
export UP, RIGHT, DOWN, LEFT
export APPLE_EATEN, VACANT, HURDLE
export INVERSE, CONST_STEP_SIZE, FILENAME, LARGE_KEY, KICK_HURDLE

# Hyperparamètres pour l'apprentissage par renforcement
const EPSILON::Float64 = 0.03
const ALPHA::Float64 = 0.9
const GAMMA::Float64 = 0.825

# Paramètres du jeu
const EMPTY::Int = 0
const APPLE::Int = 1
const WALL::Int = -1
const SNAKE_BODY::Int = 2
const SNAKE_HEAD::Int = 3
const PADDING::Int = 3
const GRID_SIZE::Int = 10 + 2 * PADDING 
const VIEW_RANGE::Int = 2                

# Directions de mouvement
const UP::Int = 1
const RIGHT::Int = 2
const DOWN::Int = 3
const LEFT::Int = 4

# Récompenses
const APPLE_EATEN::Int = 1
const VACANT::Int = 0
const HURDLE::Int = -1

# Paramètres supplémentaires
const INVERSE::Bool = false
const CONST_STEP_SIZE::Bool = true
const LARGE_KEY::Bool = false
const KICK_HURDLE::Bool = true

# Gestion des noms de fichiers 
function file_name()::String
    params = CONST_STEP_SIZE ? 
        [EPSILON, ALPHA, GAMMA, APPLE_EATEN, VACANT, HURDLE, INVERSE, CONST_STEP_SIZE, LARGE_KEY, KICK_HURDLE] :
        [EPSILON, GAMMA, APPLE_EATEN, VACANT, HURDLE, INVERSE, CONST_STEP_SIZE, LARGE_KEY, KICK_HURDLE]
    
    filename = join(params, "_")
    return replace(filename, "." => "f")
end

const FILENAME::String = file_name()

function decode_file(filename::String)::String
    decoded_filename = replace(filename, "f" => ".")   
    params = split(decoded_filename, "_")
    
    if length(params) == 10
        epsilon, alpha, gamma, apple_eaten, vacant, hurdle, inverse, const_step_size, large_key, kick_hurdle = params
        return """
        EPSILON: $epsilon
        ALPHA: $alpha
        GAMMA: $gamma
        APPLE_EATEN: $apple_eaten
        VACANT: $vacant
        HURDLE: $hurdle
        INVERSE: $inverse
        LARGE_KEY: $large_key
        CONST_STEP_SIZE: $const_step_size
        KICK_HURDLE: $kick_hurdle
        """
    elseif length(params) == 9
        epsilon, gamma, apple_eaten, vacant, hurdle, inverse, const_step_size, large_key, kick_hurdle = params
        return """
        EPSILON: $epsilon
        GAMMA: $gamma
        APPLE_EATEN: $apple_eaten
        VACANT: $vacant
        HURDLE: $hurdle
        INVERSE: $inverse
        LARGE_KEY: $large_key
        CONST_STEP_SIZE: $const_step_size        
        KICK_HURDLE: $kick_hurdle
        """
    else
        return "Le format du nom de fichier est invalide."
    end
end
#println(decode_file("0f03_0f04_0f825_1f0_0f0_-1f0_0f0_1f0_0f0_1f0"))
end



