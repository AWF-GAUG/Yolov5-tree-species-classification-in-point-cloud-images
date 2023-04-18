# This script performs a transformation from las.format 1.4 to las-format 1.2
# Store your las files in one folder and create a subfolder named "1.2"

library(lidR)
library(dplyr)
path <- "path_to_your_lasfiles" # data
files <- list.files(path, pattern = "*.las", full.names = TRUE)
file <- list.files(path, pattern = "*.las", full.names = FALSE)
for (i in 1:length(files)){
  las <- readLAS(files[i])
  lasdf <- las@data
  if (length(lasdf) > 15){
    lasdf_new <- lasdf[,c(1:3,5:9,11:14,16:18)]
    lashead <- LASheader(lasdf_new)
    lasnew <- LAS(lasdf_new, lashead)
    outfile <- paste0(path, "1.2/", file[i])
    writeLAS(las = lasnew, file = outfile)
    print(outfile)
  }
} 