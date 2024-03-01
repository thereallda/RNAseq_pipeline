# option control for R script ----
suppressWarnings(library(optparse))

option_list = list(
  make_option(c("--wd"), type="character", default=NULL, 
              help="working project directory", metavar="character")
)

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

if (is.null(opt$wd)){
  print_help(opt_parser)
  stop("Project directory must provide.", call.=FALSE)
}
# Project directory
wd <- opt$wd

# featurecounts directory
counts_dir <- paste0(wd, "results/featurecounts/")

# list all counts
file_paths <- list.files(path = counts_dir, full.names = TRUE, pattern = "txt$")

# read and combine all counts files into one table
counts_df <- Reduce(cbind, lapply(file_paths, function(i) {
  read.table(i,sep = '\t', row.names = 1, skip = 2,
             colClasses = c('character',rep('NULL',5),'integer'))
}))

# get id of files
file_id <- gsub("^.*-","",list.files(path = counts_dir,pattern = "txt$"))
file_id <- gsub("_.*txt$","",file_id)

colnames(counts_df) <- file_id
counts_df <- counts_df[, gtools::mixedorder(colnames(counts_df))]
write.csv(counts_df, file=paste0(counts_dir, "Counts.csv"), quote=FALSE)