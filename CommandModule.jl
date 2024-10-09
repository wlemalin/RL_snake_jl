module CommandModule

export parse_arguments

# Add command line argument handling
function parse_arguments()
    if length(ARGS) > 0
        if ARGS[1] == "train"
            episodes = length(ARGS) > 1 ? parse(Int, ARGS[2]) : 1000
            return true, episodes
        elseif ARGS[1] == "play"
            return false, 0
        end
    end
    return true, 1000  # default behavior
end

end
