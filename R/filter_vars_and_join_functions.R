build_slider_input <- function(df, var, varname) {
# makes a slider input
  rng <- range(df, na.rm = TRUE)
  
  sliderInput(var,
              paste0(varname, " Range:"),
              min = rng[1],
              max = rng[2],
              value = rng,
              sep = "",
              step = 1,
              ticks = FALSE
              )
}

build_picker_input <- function(df, var, varname) {
# makes a picker input
  pickerInput(var,
              paste0(varname, "(s):"), 
              choices = sort(unique(df)),
              selected = unique(df),
              options = list(`actions-box` = TRUE),
              multiple = TRUE
              )
}

build_select_input <- function(df, var, varname) {
# makes a select input
  selectInput(var,
              paste0(varname, ":"), 
              choices = sort(unique(df)),
              selected = unique(df)
              )
}

build_multi_select_input <- function(df, var, varname) {
# makes a select input ~ allowing multiple selecitons
  selectInput(var,
              paste0(varname, "(s):"),
              choices = sort(unique(df)),
              selected = unique(df),
              multiple = TRUE
              )
}

make_dropdown <- function(df, var) {
# automatically create dropdown depending on variable type
# looks up dropdown lookup where each user-filterable variable is
# listed with a dropdown instruction
  
  # convert snakecase variable name to title for ui
  varname <- str_to_title(str_replace_all(var, "_", " "))
  input_type = dropdown_lookup[[var]]
  
  if (input_type == "selectInput") {
    build_select_input(df, var, varname)
  } else if (input_type == "multiSelectInput") {
    build_multi_select_input(df, var, varname)
  } else if (input_type == "pickerInput") {
    build_picker_input(df, var, varname)
  } else if (input_type == "sliderInput") {
    build_slider_input(df, var, varname)
  } 
  
}

filter_var <- function(x, val) {
# auto filter df function
  if (is.numeric(x)) {
    !is.na(x) & x >= val[1] & x <= val[2]
  } else if (is.character(x)) {
    x %in% val
  } else {
    # No control, so don't filter
    TRUE
  }
}

group_and_summarise_excluding<- function(df, exclude_cols) {
  # group and summarise data by columns given columns to exclude
  temp <- names(df)
  
  remaining_cols <- temp [!temp %in% exclude_cols]
  
  df %>% 
    dplyr::group_by_at(remaining_cols) %>% 
    summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>% 
    mutate(units = df$units[1])
}

group_and_summarise_including <- function(df, include_cols) {
  # group and summarise data by columns given columns to include
  
  df %>% 
    dplyr::group_by_at(include_cols) %>% 
    summarise(value = sum(value, na.rm = TRUE), .groups = 'drop_last') %>% 
    mutate(units = df$units[1])
}