module ExtractRoxygenBlocks

include("defaults.jl")
import .Defaults
include("extract_text_blocks.jl")
import .ExtractTextBlocks

function extract_roxygen_blocks(
    file_path::String
    ;
    detect_block_begins::Function = roxygen_defaults[:detect_block_begins],
    detect_block_includes::Function = Defaults.roxygen_defaults[:detect_block_includes],
    detect_block_ends::Function = Defaults.roxygen_defaults[:detect_block_ends],
    detect_block_ended::Function = Defaults.roxygen_defaults[:detect_block_ended],
    detect_allowed_key::Function = Defaults.roxygen_defaults[:detect_allowed_key],
    extract_line::Function = Defaults.roxygen_defaults[:extract_line],
    extract_key::Function = Defaults.roxygen_defaults[:extract_key]
)::df.AbstractDataFrame
    ExtractTextBlocks.extract_blocks(
        file_path,
        detect_block_begins = detect_block_begins,
        detect_block_includes = detect_block_includes,
        detect_block_ends = detect_block_ends,
        detect_block_ended = detect_block_ended,
        detect_allowed_key = detect_allowed_key,
        extract_line = extract_line,
        extract_key = extract_key
    )
end

end
