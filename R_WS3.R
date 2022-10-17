library(palmerpenguins)
library(tidyverse)

# Question 1 ---------------------------------
View(penguins)

xtab <- 
  penguins %>%
  count(island, species) %>%
  pivot_wider(names_from = "species",
              values_from = "n")

xtab %>%
  rowwise() %>%
  mutate(Total = sum(Adelie, Gentoo, Chinstrap, na.rm = TRUE)) %>%
  ungroup() %>%
  bind_rows(
    .,
    summarise(., 
      island = "Total",
      Adelie = sum(Adelie),
      Gentoo = sum(Gentoo, na.rm = TRUE),
      Chinstrap = sum(Chinstrap, na.rm = TRUE),
      Total = sum(Total)
    )
  )

  # summarise_all(., ~if(is.numeric(.)) sum(., na.rm = TRUE) else "Total")
  
# Alternatively
penguins %>%
  select(island, species) %>%
  table()  # uses base R (but no row/col summaries)

# Hint 1:
# pivot_wider or pivot_longer
# long vs wide?
# 
# Sketch / jot down the contingency table on paper
# 
# Hint 2:
# 
# Go rogue! Find a package that does contingency tables
# 

# Example of pivot_wider
fish_encounters
fish_encounters %>%
  pivot_wider(names_from = station,
              values_from = seen)





