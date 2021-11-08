module TextBlockExtractor
    
    include("extract_text_blocks.jl")
    import .ExtractTextBlocks

    extract_text_blocks = ExtractTextBlocks.extract_text_blocks

    precompile(extract_text_blocks, (String, ))

end