# Get file list
args = commandArgs(trailingOnly=TRUE)
folder = args[1]

files = dir(
  path = folder,
  full.names = TRUE,
  pattern = ".{3,}xml$",
  include.dirs = FALSE)

# Extract all files
all_xml = lapply(files, function(this) {
  xml_li = XML::xmlToList(this)
  xml_ch = unlist(xml_li)
  roles = data.frame(
    key = xml_ch,
    value = names(xml_ch),
    stringsAsFactors = FALSE)
  roles$value = gsub("permissions.", "", roles$value)
  setNames(roles, c("key", this))
})

# Merge all files
res = Reduce(function(x, y) merge(x, y, by = "key", all = TRUE), all_xml)
res = res[order(res$key), ]

# Export xlsx
openxlsx::write.xlsx(res, file = paste(folder, "merged.xlsx", sep = "/"))
message("Output in '", paste(folder, "merged.xlsx", sep = "/"), "'")

