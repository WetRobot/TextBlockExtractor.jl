module Defaults

defaults = Dict(
    :detect_block_begins => function(line::AbstractString)
        contains(line, r"@codedoc_comment_block")
    end,
    :detect_block_includes => function(line::AbstractString)
        contains(line, r"^[ #]*")
    end,
    :detect_block_ends => function(line::AbstractString, key::AbstractString)
        contains(line, Regex("@codedoc_comment_block[ ]*$key"))
    end,
    :detect_block_ended => function(line::AbstractString)
        false
    end,
    :detect_allowed_key => function(key::AbstractString)
        true
    end,
    :extract_line => function(line::AbstractString)
        replace(line, r"^[ #]*" => s"")
    end,
    :extract_key => function(line::AbstractString)
        replace(line, r"^[ #]*@codedoc_comment_block[ ]*" => s"")
    end
)

roxygen_defaults = Dict(
    :detect_block_begins => function(line::AbstractString)
        contains(line, r"[ ]*#' @")
    end,
    :detect_block_includes => function(line::AbstractString)
        contains(line, r"[ ]*#'")
    end,
    :detect_block_ends => function(line::AbstractString, key::AbstractString)
        false
    end,
    :detect_block_ended => function(line::AbstractString)
        contains(line, r"[ ]*#' @") || !contains(line, r"[ ]*#' ")
    end,
    :detect_allowed_key => function(key::AbstractString)
        true
    end,
    :extract_line => function(line::AbstractString)
        replace(line, r"[ ]*#' " => s"")
    end,
    :extract_key => function(line::AbstractString)
        replace(line, r"[ ]*#' @" => s"")
    end
)

end
