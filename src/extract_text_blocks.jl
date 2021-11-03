module ExtractTextBlocks

import DataFrames

include("defaults.jl")
import .Defaults

"""
    extract_text_blocks(
        file_path::String
        ;
        detect_block_begins::Function = Defaults.defaults[:detect_block_begins],
        detect_block_includes::Function = Defaults.defaults[:detect_block_includes],
        detect_block_ends::Function = Defaults.defaults[:detect_block_ends],
        detect_block_ended::Function = Defaults.defaults[:detect_block_ended],
        detect_allowed_key::Function = Defaults.defaults[:detect_allowed_key],
        extract_line::Function = Defaults.defaults[:extract_line],
        extract_key::Function = Defaults.defaults[:extract_key]
    )::DataFrames.AbstractDataFrame

# Arguments

## Mandatory arguments

- `file_path::String`: 
  Path to a file; text blocks will be extracted from this file.

## Keyword arguments

- `detect_block_begins::Function = Defaults.defaults[:detect_block_begins]`:
  Function with one mandatory argument; should return `true` if input
  line is the first line in a block.
- `detect_block_includes::Function = Defaults.defaults[:detect_block_includes]`:
  Function with one mandatory argument; should return `true` if input
  line is considered part of any block.
- `detect_block_ends::Function = Defaults.defaults[:detect_block_ends]`:
  Function with one mandatory argument; should return `true` if input
  line is (potentially) the last line in a block.
- `detect_block_ended::Function = Defaults.defaults[:detect_block_ended]`:
  Function with one mandatory argument; should return `true` if input
  line is (potentially) right after the last line in a block.
- `detect_allowed_key::Function = Defaults.defaults[:detect_blodetect_allowed_keyck_ends]`:
  Function with one mandatory argument; should return `true` if input
  key is allowed to be extracted (is not ignored)
- `extract_line::Function = Defaults.defaults[:extract_line]`:
  Function with one mandatory argument; should return the input line
  after any clean-up. E.g. can be used to comment character "#" from the line.
- `extract_key::Function = Defaults.defaults[:extract_key]`:
  Function with one mandatory argument; should return the key from
  a line that contains a key.
"""
function extract_text_blocks(
    file_path::String
    ;
    detect_block_begins::Function = Defaults.defaults[:detect_block_begins],
    detect_block_includes::Function = Defaults.defaults[:detect_block_includes],
    detect_block_ends::Function = Defaults.defaults[:detect_block_ends],
    detect_block_ended::Function = Defaults.defaults[:detect_block_ended],
    detect_allowed_key::Function = Defaults.defaults[:detect_allowed_key],
    extract_line::Function = Defaults.defaults[:extract_line],
    extract_key::Function = Defaults.defaults[:extract_key]
)::DataFrames.AbstractDataFrame

    first_line_no_by_block = Int32[]
    last_line_no_by_block = Int32[]
    lines_by_block = Vector{Vector{String}}()
    key_by_block = String[]

    active_block_no_set = Int32[]
    line_no = 0
    for line in eachline(file_path)        
        line_no += 1
        is_included = detect_block_includes(line)        
        is_after_last_line = detect_block_ended(line)
        if is_after_last_line
            push!(last_line_no_by_block, line_no - 1)
            continue # done here, go to next block_no
        end
        if !is_included
            continue # done here, go to next line
        end
        key = extract_key(line)
        is_allowed_key = detect_allowed_key(key)
        is_key_line = is_allowed_key && key != "" && key != line
        is_first_line = detect_block_begins(line)
        active_key_set = key_by_block[active_block_no_set]
        is_first_line = is_first_line && !(key in active_key_set)
        if is_first_line
            push!(key_by_block, key)
            push!(first_line_no_by_block, line_no)
            new_block_no = length(first_line_no_by_block)
            push!(active_block_no_set, new_block_no)
            push!(lines_by_block, String[])
            continue # done here, go to next line
        end

        extracted_line = extract_line(line)         
        for block_no in active_block_no_set 
            key = key_by_block[block_no]
            is_last_line = detect_block_ends(line, key)
            if is_last_line
                # we know the block ends here.    
                setdiff!(active_block_no_set, block_no)
                push!(last_line_no_by_block, line_no)
                continue # done here, go to next block_no
            end            

            if is_included && !is_key_line && !is_first_line && !is_last_line  
                # line is one of the lines that comprise the block,
                # so we collect it. 
                push!(lines_by_block[block_no], extracted_line)
            end
        end # block_no for loop
    end # line for loop

    out = DataFrames.DataFrame(
        first_line_no = first_line_no_by_block,
        last_line_no = last_line_no_by_block,
        key = key_by_block,
        block = lines_by_block
    )
    return(out)

end


end
