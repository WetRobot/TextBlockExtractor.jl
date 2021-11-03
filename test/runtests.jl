
import Test
import JLD
import TextBlockExtractor
import DataFrames

data_dir = joinpath(dirname(pathof(TextBlockExtractor)), "..", "data", "examples") 
example_1_result = TextBlockExtractor.extract_text_blocks(
    joinpath(data_dir, "example_1_data.R") 
)
example_1_expected = JLD.load(
    joinpath(data_dir, "example_1_expected.jld") , "example_1_expected"
)
for row_no = 1:DataFrames.nrow(example_1_expected)
    for col_no = 1:DataFrames.ncol(example_1_expected)
        Test.@test example_1_result[row_no, col_no] == example_1_expected[row_no, col_no]
    end
end




