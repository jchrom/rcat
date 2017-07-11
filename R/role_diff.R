#' List all files by suffix (exclude all directories).
#'
#' @param suffix desired suffix
#' @param folder folder containing files
#' @importFrom dplyr %>% filter

list_by = function(suffix, folder) {

  xml_list = dir(
    path = folder,
    full.names = TRUE,
    pattern = paste0(suffix, "$"),
    include.dirs = FALSE)

  xml_files =
    file.info(xml_list) %>%
    tibble::rownames_to_column("file.name") %>%
    filter(!isdir)

  xml_files$file.name

}

#' Find Role Differences
#'
#' Exports table with permissions for all 2 or more XML files exported from the Define roles page in Moodle.
#'
#' @param folder folder containing XML files (and where the output will go)
#' @param suffix Defaults to "XML"
#'
#' @return A XLSX file containing table with all the permission values
#' @export

role_diff = function(folder = ".", suffix = "xml") {

  xml_files = list_by(suffix = suffix, folder = folder)

  xml_lst = lapply(xml_files, function(this) {
    xml_li = XML::xmlToList(this)
    xml_ch = unlist(xml_li)
    roles = data.frame(
      key = xml_ch,
      value = names(xml_ch),
      stringsAsFactors = FALSE)
    roles$value = gsub("permissions.", "", roles$value)
    setNames(roles, c("key", this))
  })

  res = Reduce(function(x, y)
    merge(x, y, by = "key", all = TRUE), xml_lst)
  res = res[order(res$key), ]

  openxlsx::write.xlsx(res, file = paste(folder, "merged.xlsx", sep = "/"))
  message("Output in '", paste(folder, "merged.xlsx", sep = "/"), "'")
}
