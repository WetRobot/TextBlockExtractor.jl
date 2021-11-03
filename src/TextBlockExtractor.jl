module TextBlockExtractor
    
    include("extract_text_blocks.jl")
    import .ExtractTextBlocks

    extract_text_blocks = ExtractTextBlocks.extract_text_blocks

    #export extract_text_blocks

end