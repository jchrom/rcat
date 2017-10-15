# Export questions in Moodle XML format
# input: spreadsheet, output: moodle XML
# question types: core
# how it works: It has XML templates into which data can be inserted

library(xml2)
library(dplyr)
library(tidyr)
library(purrr)

# Proof of concept: the truefalse question type
# [DONE] template with default values
# [DONE] function that can load the template
# [] function that will fill in values from data.frame
# [] function that will export a Moodle xml file

# Truefalse: create template with default values ----
# ---------------------------------------------------

quiz = read_xml("dev/data/questions.xml") %>% as_list()
quiz = quiz[!sapply(names(quiz), identical, "")]

lapply(quiz, function(x) {
  list(quiz = list(question = x)) %>%
  as_xml_document() %>%
  write_xml(paste0("dev/templates_xml/", attributes(x)$type, ".xml"))
})

# Then edit manually missing feedback text (beware empty text tag is <text/>
# but when adding a text it needs to change to proper closing tag </text> which
# has the slash on the front and not back!)

# Truefalse: Function to load the template ----
# ---------------------------------------------

load_xml_template = function(template) {
  #provisional, instead of system.file
  path = file.path("dev", "templates_xml", paste0(template, ".xml"))
  as_list(read_xml(path))
}

# Truefalse: fill values ----
# ---------------------------

x = load_xml_template("truefalse")$question
y = read.csv("dev/data/questions.csv", stringsAsFactors = FALSE) #spreadsheet with questions

# Assumptions: The spreadsheets has all the necessary fileds, and only if they
# are NA, the defaults are used

# Here we have all the raw questions plus templates as a list and unlisted
df = y %>%
  as_tibble() %>%
  nest(answer.text, answer.feedback.text, fraction) %>%
  mutate(xml = map(question.type, load_xml_template),
         li = map(xml, unlist))

# We need a prototype - a loop that goes over the unlisted chr and searches
# the df for values
a = df[1, ]
b = df$li[[1]]

for (arg in names(b)) {
  print(arg)

}

fill_values = function(x, y, name = "Question name", text = "Question text",
                       generalfeedback = "General feedback",
                       defaultgrade = 1, penalty = 0, hidden = 0,
                       answer.text = c("true", "false"),
                       fraction = c(100, 0), format = "moodle_auto_format",
                       answer.feedback = c("true", "false")
                       ) {


}
