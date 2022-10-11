# Tuesday 11/10/2022
# R3 Live Coding Lecture
# 
# If you haven't installed the tidyverse package, run
# install.packages("tidyverse")
# 
# Topics:
# 1. Tidy data 
# 2. Tibbles
# 3. Pipeline
# 4. tidyverse commands for manipulating data in R
# 5. (just a bit) on RESHAPING data in R

# Packages
library(tidyverse)
# library(tibble)  # this is included in tidyverse anyway

# Introducing tidy datasets and tibbles ----------------------------------------
tidyr::billboard[, 1:7]
View(tidyr::billboard[, 1:7])

# Tibbles versus data frames
iris  # a data frame
str(iris)
tbl_iris <- as_tibble(iris)  # coerce to tibbles
tbl_iris

# Tibbles are lazy
tbl_iris[1, ] # subsetting the first row
tbl_iris[, 1] # subset the first column
iris[, 1]  # this subsets the first column from a data frame
           # it gets converted into a vector!

# Tibbles do not use partial matching
colnames(iris)
iris$Sp # this is the same as iris$Species
tbl_iris$Sp  # this doesn't work!


# How do you create a tibble
t <- tibble(
  x = 1:3,
  y = c("A", "B", "C"),
  z = factor(c("X", "Y", "Z"))
)
# Similar to how you would write a list or data.frame

# Length coercion?
tibble(x = 1:4, y = 1)  # this is fine.
tibble(x = 1:4, y = 1:2)  # this is not!

# Pipeline ---------------------------------------------------------------------
# Slide 14
data.frame(a = 1:3, b = 3:1) %>%
  lm(formula = a ~ b)  # look at ?lm

# The above code is the same as 
data.frame(a = 1:3, b = 3:1) %>%
  lm(formula = a ~ b, data = .) 

# Useful for cases like this:
data.frame(a = 1:3, b = 3:1) %>%
  .[[1]]

# or this
data.frame(a = 1:3, b = 3:1) %>%
  .[[length(.)]]

# Functions for data manipulation ----------------------------------------------
# filter
library(dplyr)
library(nycflights13) # install.packages("nycflights13")
flights # this is the tibble

# I want to look at flights in March
flights %>%
  filter(month == 3)

flights %>%
  filter(month == 3, day <= 7)

# Flights to LAX *or* JFK in March
flights %>%
  filter(dest == "LAX" | dest == "JFK", month == 3)

# How do I know what columns are available?
View(flights)
colnames(flights)

# Slice
flights %>%
  slice(1:10) # the first 10 rows

# Last 5 flights
flights %>%
  slice((n() - 4):n()) # do not use this

flights %>%
  slice_tail(n = 5)

# Select columns 
flights %>%
  select(year, month, day)

flights %>%
  select(-year, -month, -day)

flights %>%
  select(year:day) # inspect the colnames

# Selecting columns containing certain names
flights %>%
  select(contains("dep"),
         contains("arr"))

flights %>%
  select(starts_with("dep"))

# other helpers provided by tidyselect: starts_with, ends_with everything,
# matches, num_range, one_of, everything, last_col Take a look at the tidyselect
# page https://tidyselect.r-lib.org/reference/language.html

# Select only numeric columns
flights %>%
  select(where(is.numeric))

# This is kind of like doing the following
str(flights)
is.numeric(flights[[1]])
is.numeric(flights[[2]]) # and so on... tedious

# Relocate to the front
flights %>%
  relocate(carrier, origin, dest)

# Relocate to the back
flights %>%
  relocate(carrier, origin, dest, .after = last_col())

# Rename columns
flights %>%
  rename(tail_number = tailnum) # new_name = old_name

# Sort data
flights %>%
  filter(month == 3, day == 2) %>%
  arrange(origin, dest) 

# Sort data in descending order
flights %>% # start with a data set
  filter(month == 3, day == 2) %>% # filter flights on 2nd march
  arrange(desc(origin), dest) %>% # sort origin (descending) then by dest
  select(origin, dest, tailnum) # select only these 3 columns

# Mutate (modify columns)
flights %>%
  select(year:day) %>%
  mutate(
    date = paste(year, month, day, sep = "/") %>%
      as.Date()
  )

# Distinct (find unique rows)
flights %>%
  select(origin, dest) %>%
  distinct()

# Summarising
flights %>%
  summarise(count = n(),
            min = min(dep_delay, na.rm = TRUE),
            max = max(dep_delay, na.rm = TRUE))

x <- c(1, 2, 3, NA)
min(x, na.rm = TRUE)

# Summarise by groups
flights %>%
  group_by(origin) %>%
  summarise(count = n(),
            min = min(dep_delay, na.rm = TRUE),
            max = max(dep_delay, na.rm = TRUE))

# unique(flights$origin) # just to see what the 3 groups are

# Mutate in groups
# This is the difference between summarise and mutate
# Summarise reduces the number of rows while mutate keeps the number of rows
flights %>%
  group_by(month) %>%
  mutate(max_delay = max(dep_delay, na.rm = TRUE)) %>%
  select(month, max_delay)

# Wide vs Long data sets -------------------------------------------------------
# n > p (this is tall and skinny)
# p > n (this is wide and short)
d <- tribble(
  ~country, ~"1999", ~"2000",
       "A",  "0.7K",    "2K",
       "B",   "37K",   "80K",
       "C",  "212K",  "213K",
)
d_long <-
  pivot_longer(d, cols = c("1999", "2000"),
               names_to = "year",
               values_to = "cases")

pivot_wider(d_long, id_cols = c("country"),
            names_from = year,
            values_from = cases)
