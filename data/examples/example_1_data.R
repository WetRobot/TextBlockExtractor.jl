
codedoc_insert_comment_blocks <- function(
  block_df,
  subset
) {
  dbc::assert_prod_input_is_data.frame_with_required_names(
    block_df,
    required_names = c("comment_block", "key")
  )
  dbc::assert_prod_input_is_logical_nonNA_vector(subset)
  re <- codedoc_insert_comment_block_regex()

  block_df[["comment_block"]][subset] <- lapply(
    block_df[["comment_block"]][subset],
    function(lines) {
      # @codedoc_comment_block codedoc_insert_comment_blocks_details
      #
      # - lines with insert keys are detected using regex
      #   "${codedoc_insert_comment_block_regex()}"
      #
      # @codedoc_comment_block codedoc_insert_comment_blocks_details
      is_insert_line <- grepl(re, lines)
      tick <- 0L
      while (any(is_insert_line)) {
        # @codedoc_comment_block codedoc_insert_comment_blocks_details
        #
        # - all lines are passed through a maximum of ten times. this means
        #   that a recursion depth of ten is the maximum. recursion can occur
        #   if a comment block is inserted which in turn has one or more
        #   insert keys.
        #
        # @codedoc_comment_block codedoc_insert_comment_blocks_details
        tick <- tick + 1L
        if (tick == 10L) {
          stop("hit 10 passes in while loop when inserting comment blocks; ",
               "do you have self-referencing in a comment block?")
        }
        for (i in 1:sum(is_insert_line)) {
          # @codedoc_comment_block codedoc_insert_comment_blocks_details
          #
          # - insert keys are collected by removing the regex given above,
          #   anything preceding it, and all whitespaces after it
          #
          # @codedoc_comment_block codedoc_insert_comment_blocks_details
          insert_key_by_line <- sub(
            paste0(".*", re, "[ ]*"),
            "",
            lines
          )
          insert_key_by_line[!is_insert_line] <- NA_character_
          wh <- which(is_insert_line)[1L]
          insert_key <- insert_key_by_line[wh]
          if (!insert_key %in% block_df[["key"]]) {
            stop("found insert key which has no match in collected comment ",
                 "block keys. invalid key: ", deparse(insert_key),
                 "; collected keys: ", deparse(block_df[["key"]]))
          }
          # @codedoc_comment_block codedoc_insert_comment_blocks_details
          #
          # - each line with an insert key is effectively replaced with
          #   all lines in the comment block of that key (e.g. line with key
          #   "my_key" is replaced with all lines in comment block with key
          #   "my_key"). this is run separately for each detected insert key.
          #
          # @codedoc_comment_block codedoc_insert_comment_blocks_details
          add_lines <- unlist(
            block_df[["comment_block"]][block_df[["key"]] == insert_key]
          )
          head_lines <- character(0L)
          if (wh > 1L) {
            head_lines <- lines[1L:(wh - 1L)]
          }
          tail_lines <- character(0L)
          if (wh < length(lines)) {
            tail_lines <- lines[(wh + 1L):length(lines)]
          }
          lines <- c(head_lines, add_lines, tail_lines)
          is_insert_line <- grepl(re, lines)
        }
      }
      # @codedoc_comment_block codedoc_insert_comment_blocks_details
      #
      # - the result is still a character vector, but here the insert keys
      #   have been replaced with lines from the comment blocks under those keys
      #
      # @codedoc_comment_block codedoc_insert_comment_blocks_details
      return(lines)
    }
  )

  return(block_df)
}

