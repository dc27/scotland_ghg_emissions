make_dropdown <- function(df, var) {
  # convert snakecase variable name to title for ui
  varname <- str_to_title(str_replace_all(var, "_", " "))
  if (is.numeric(df)) {
    rng <- range(df, na.rm = TRUE)
    sliderInput(var,
                paste0(varname, " Range:"),
                min = rng[1],
                max = rng[2],
                value = rng,
                sep = "",
                step = 1,
                ticks = FALSE)
  } else if (is.character(df)) {
    pickerInput(var,
                paste0(varname, "(s):"), 
                choices = sort(unique(df)),
                selected = unique(df),
                options = list(`actions-box` = TRUE),
                multiple = TRUE)
  } else {
    NULL
  }
}

filter_var <- function(x, val) {
  if (is.numeric(x)) {
    !is.na(x) & x >= val[1] & x <= val[2]
  } else if (is.character(x)) {
    x %in% val
  } else {
    # No control, so don't filter
    TRUE
  }
}