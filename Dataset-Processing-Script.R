library(tidyverse)
library(codebookr)
load("raw-data/DS0001/38892-0001-Data.rda")

set.seed(47)

# SELECTING COLUMNS -------------------------------------------------------

# taking a subset of variables, prioritizing common indirect identifiers and more sensitive variables;
# excluding household variables (e.g., number of people of X age in your household) for simplicity;
# some free-text columns are masked by ICPSR, but we're keeping one so we can fill it in with fake random values;
# considered but decided to exclude the masked demographic columns for a mix of two reasons:
# 1. Including them is unrealistic for k-anonymity: you wouldn't run local suppression without doing something about
#    all these free-text values because it shreds data utility, but users don't have time for that in our study
# 2. For some of the columns, many of the real answers are not very serious (see codebook)
selected_cols <- c(
  "AGE_YEAR_D16",
  "CURRENT_RES_LEN_D16",
  "CITY_RES_LEN_D16",
  "INSURED_D16",
  "DISAB_IDENTIFY_D16",
  "DISAB_AUT_SELF_D16",
  "DISAB_VISUAL_SELF_D16",
  "DISAB_HEAR_SELF_D16",
  "DISAB_INTELL_SELF_D16",
  "DISAB_LEARN_SELF_D16",
  "DISAB_MENTAL_SELF_D16",
  "DISAB_MOBIL_SELF_D16",
  "DISAB_OTHER_SELF_D16",
  "MH_ANXIETY_D16",
  "MH_WORRY_D16",
  "MH_DEPRESS_D16",
  "DEBT_CREDITCARD_D16",
  "DEBT_HOMELOAN_D16",
  "DEBT_PERSONLOAN_D16",
  "DEBT_STUDENT_D16",
  "DEBT_PAYDAYLOAN_D16",
  "DEBT_LAYAWAY_D16",
  "DEBT_INFORMALLOAN_D16",
  "DEBT_OTHER_D16",
  "DEBT_OTHER_TEXT_D16",
  "LOAN_DENIED_D16",
  "MORT_DENIED_D16",
  "HHDEBT_LEVEL_D16",
  "EVICT_5YRS_D16",
  "ANYWORK_D16",
  "NOWORK_LENGTH_D16",
  "FIN_PUBASSIST_UI_MONTH_D16",
  "PID_D16",
  "LANGUAGE_D16",
  "BORN_US_D16",
  "GENDER_D16",
  "SEXUALITY_D16",
  "HISP_D16",
  "MIDEASTERN_D16",
  "RACE_WHITE_D16",
  "RACE_BLACK_D16",
  "RACE_ASIAN_D16",
  "RACE_NATIVE_D16",
  "RACE_PACISL_D16",
  "RACE_OTHER_D16",
  "EDUC_D16",
  "MARITAL_D16",
  "INCOME_2_D16",
  "INCOME_3_D16"
)
col_renames <- c(
  birth_year = "AGE_YEAR_D16",
  time_at_current_address = "CURRENT_RES_LEN_D16",
  time_in_Detroit = "CITY_RES_LEN_D16",
  has_health_insurance = "INSURED_D16",
  disabled = "DISAB_IDENTIFY_D16",
  disab_neurodivergence = "DISAB_AUT_SELF_D16",
  disab_visual = "DISAB_VISUAL_SELF_D16",
  disab_hearing = "DISAB_HEAR_SELF_D16",
  disab_intellectual = "DISAB_INTELL_SELF_D16",
  disab_learning = "DISAB_LEARN_SELF_D16",
  disab_mental_health = "DISAB_MENTAL_SELF_D16",
  disab_mobility = "DISAB_MOBIL_SELF_D16",
  disab_other = "DISAB_OTHER_SELF_D16",
  anxious_past_week = "MH_ANXIETY_D16",
  worried_past_week = "MH_WORRY_D16",
  depressed_past_week = "MH_DEPRESS_D16",
  debt_credit_card = "DEBT_CREDITCARD_D16",
  debt_mortgage_loan = "DEBT_HOMELOAN_D16",
  debt_personal_bank_loan = "DEBT_PERSONLOAN_D16",
  debt_student_loan = "DEBT_STUDENT_D16",
  debt_payday_loan = "DEBT_PAYDAYLOAN_D16",
  debt_installment_plan = "DEBT_LAYAWAY_D16",
  debt_informal_loan = "DEBT_INFORMALLOAN_D16",
  debt_other = "DEBT_OTHER_D16",
  debt_other_description = "DEBT_OTHER_TEXT_D16",
  loan_denied_past_5_years = "LOAN_DENIED_D16",
  mortgage_denied_past_5_years = "MORT_DENIED_D16",
  household_debt_level = "HHDEBT_LEVEL_D16",
  evicted_past_5_years = "EVICT_5YRS_D16",
  employed_past_month = "ANYWORK_D16",
  time_unemployed = "NOWORK_LENGTH_D16",
  unemployment_insurance_past_month = "FIN_PUBASSIST_UI_MONTH_D16",
  political_affiliation = "PID_D16",
  speaks_non_english_language_at_home = "LANGUAGE_D16",
  born_in_US = "BORN_US_D16",
  gender = "GENDER_D16",
  sexuality = "SEXUALITY_D16",
  ethnicity_hispanic = "HISP_D16",
  ethnicity_middle_eastern = "MIDEASTERN_D16",
  race_white = "RACE_WHITE_D16",
  race_black = "RACE_BLACK_D16",
  race_asian = "RACE_ASIAN_D16",
  race_native_american = "RACE_NATIVE_D16",
  race_pacific_islander = "RACE_PACISL_D16",
  race_other = "RACE_OTHER_D16",
  education = "EDUC_D16",
  marital_status = "MARITAL_D16",
  household_income_below_35k = "INCOME_2_D16",
  household_income_above_35k = "INCOME_3_D16"
)
col_questions <- c(
  birth_year = "When were you born?",
  time_at_current_address = "About how long have you lived at your current address?",
  time_in_Detroit = "About how long have you lived in Detroit?",
  has_health_insurance = "Do you have any kind of health insurance or health care plan? This includes health insurance you get from your job or school, that you buy yourself, and programs like Medicare and Medicaid.",
  disabled = "Do you identify as disabled or a person with a disability?",
  disab_neurodivergence = "Do you consider yourself to have any of the following? Autism/neurodivergence/neuroatypicality",
  disab_visual = "Do you consider yourself to have any of the following? Blindness or a visual impairment",
  disab_hearing = "Do you consider yourself to have any of the following? Deafness or a hearing impairment",
  disab_intellectual = "Do you consider yourself to have any of the following? An intellectual or cognitive disability, including serious difficulty remembering, concentrating, or making decisions",
  disab_learning = "Do you consider yourself to have any of the following? A learning disability",
  disab_mental_health = "Do you consider yourself to have any of the following? A mental health or psychiatric condition",
  disab_mobility = "Do you consider yourself to have any of the following? A mobility limitation or disability",
  disab_other = "Do you consider yourself to have any of the following? Another chronic illness or disability",
  anxious_past_week = "Now we would like to ask a standard set of questions asked by health professionals to assess your mental wellbeing. In the past 7 days, how often have you... felt nervous, anxious, or on edge?",
  worried_past_week = "Now we would like to ask a standard set of questions asked by health professionals to assess your mental wellbeing. In the past 7 days, how often have you... not been able to stop or control worrying?",
  depressed_past_week = "Now we would like to ask a standard set of questions asked by health professionals to assess your mental wellbeing. In the past 7 days, how often have you... felt depressed?",
  debt_credit_card = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Credit cards (or mobile wallet “cards”)",
  debt_mortgage_loan = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Mortgage loan/home loan/land contract",
  debt_personal_bank_loan = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Personal loan/line of credit from a bank, including a car loan",
  debt_student_loan = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Student loan",
  debt_payday_loan = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Payday loan",
  debt_installment_plan = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Layaway/installment plan",
  debt_informal_loan = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Informal loan from family/friends",
  debt_other = "Are you or is someone in your household currently paying oﬀ any of the following types of debt? Other",
  debt_other_description = "Please describe the reason you selected ‘Other’ on the previous question about types of debt: (TEXT BOX)",
  loan_denied_past_5_years = "Was there any time in the past 5 years that you or someone else in your household was unable to get a loan or credit card?",
  mortgage_denied_past_5_years = "Was there any time in the past 5 years that you or someone else in your household was unable to get a mortgage loan for a house you/they wanted to purchase?",
  household_debt_level = "As of today, which of the following statements best describes how manageable your household debt is?",
  evicted_past_5_years = "Have you been evicted or forced to move from your home in the last 5 years ?",
  employed_past_month = "In the past month, did you do any work for either pay or profit?",
  time_unemployed = "How long have you been out of work?",
  unemployment_insurance_past_month = "In the past month, have you received unemployment Insurance (UI) benefits?",
  political_affiliation = "Generally speaking, do you usually think of yourself as a Republican, a Democrat, an Independent, or what?",
  speaks_non_english_language_at_home = "Do you speak a language other than English at home?",
  born_in_US = "Were you born in the United States or a U.S. territory?",
  gender = "What is your gender?",
  sexuality = "Which of the following best describes how you think of yourself?",
  ethnicity_hispanic = "Are you of Hispanic, Latino, or Spanish origin, such as Mexican, Puerto Rican or Cuban?",
  ethnicity_middle_eastern = "Are you of Arab, Persian, or Middle Eastern descent?",
  race_white = "Which of the following best describes your race? Please select all that apply: White",
  race_black = "Which of the following best describes your race? Please select all that apply: Black or African-American",
  race_asian = "Which of the following best describes your race? Please select all that apply: Asian or Asian-American",
  race_native_american = "Which of the following best describes your race? Please select all that apply: American Indian or Alaska Native",
  race_pacific_islander = "Which of the following best describes your race? Please select all that apply: Native Hawaiian or Other Pacific Islander",
  race_other = "Which of the following best describes your race? Please select all that apply: Other",
  education = "What is the highest degree or level of school you have completed?",
  marital_status = "Are you now married, widowed, divorced, separated or never married?",
  household_income = "We would like to get a better estimate of your total HOUSEHOLD income in the past 12 months before taxes. Was it…"
)
# ordinal_cols <- c(
#   'birth_year',
#   'time_at_current_address',
#   'time_in_Detroit',
#   'anxious_past_week',
#   'worried_past_week',
#   'depressed_past_week',
#   'household_debt_level',
#   'time_unemployed',
#   'education',
#   'household_income'
# )

# SIMPLIFYING AND CLARIFYING DATA -----------------------------------------

df <- da38892.0001 |>
  select(all_of(selected_cols)) |>
  rename(all_of(col_renames)) |>
  
  # for ease of editing, cast factor columns temporarily as character
  mutate(across(where(is.factor), as.character)) |>
  
  # combine the two household income columns
  mutate(household_income = ifelse(!(household_income_below_35k %in% c("(-99) Skipped", "(-88) System Missing")),
                                   household_income_below_35k,
                                   ifelse(!(household_income_above_35k %in% c("(-99) Skipped", "(-88) System Missing")),
                                          household_income_above_35k,
                                          "(-99) Skipped"))) |>
  select(-household_income_below_35k, -household_income_above_35k) |>
  
  # disambiguate "System Missing" values
  mutate(time_unemployed = ifelse(employed_past_month == "(-99) Skipped",
                                  "(-99) Skipped",
                                  ifelse(employed_past_month == "(1) Yes",
                                         "(0) None (currently employed)",
                                         time_unemployed))) |>
  mutate(unemployment_insurance_past_month = ifelse(employed_past_month == "(-99) Skipped",
                                                    "(-99) Skipped",
                                                    ifelse(employed_past_month == "(1) Yes",
                                                           "(0) No",
                                                           unemployment_insurance_past_month))) |>
  
  # # use NA consistently for missing/irrelevant values
  # mutate(birth_year = replace(birth_year,
  #                             birth_year == -99,
  #                             NA)) |>
  
  # generalize birth_year and use NA consistently for missing/irrelevant values
  mutate(birth_year = as.factor(ifelse(birth_year == -99,
                                       NA,
                                       str_glue("{substr(birth_year, 1, 3)}0 to {substr(birth_year, 1, 3)}9")))) |>
  mutate(across(where(is.character), ~ replace(.x,
                                               .x %in% c("(-99) Skipped", "(-88) System Missing"),
                                               NA))) |>
  
  # cast columns back to factor and remove codes from values (e.g., "(0) No" becomes "No")
  mutate(across(where(is.character), as.factor)) |>
  # # set ordered factor levels for ordinal columns based codes
  # # order is wrong for household income
  # mutate(across(all_of(ordinal_cols), ordered)) |>
  mutate(across(where(is.factor), ~ fct_relabel(.x, ~ sub("\\(-?\\d+\\) ", "", .x)))) |>
  
  # reformat values with double $ signs, which trigger math notation in Jupyter notebooks
  mutate(household_income = fct_relabel(household_income, ~ sub("(\\$.+)\\$", "\\1", .x)))
  
  # add question text for the codebook
  for(col in names(col_questions)) {
    attr(df[[col]], "description") <- col_questions[[col]]
  }

# FILLING MASKED VALUES WITH SYNTHETIC DATA -------------------------------

# replace ICPSR-masked values with fake random values in a given column vector
replace_masked <- function(col, replacement_pool, replace = TRUE) {
  col[!is.na(col)] <- sample(
    replacement_pool,
    sum(!is.na(col)),
    replace = replace
  )
  
  return(col)
}

# named vector where names are column names, and values are pools of potential replacement values for a given column
col_replacements <- list(
  debt_other_description = c(
    "Medical bills from a recent surgery", "Paying off a hospital stay from last year", "Still working on ER visit debt",
    "Debt from cancer treatments", "Owe money for physical therapy sessions", "Paying installments on a large hospital bill",
    "Medical debt from a car accident", "Bills from multiple specialist visits", "Ongoing payments for past emergency care",
    "Stuck with debt from an uninsured procedure", "Paying off childbirth-related medical expenses", "Left with debt after a major operation",
    "Debt from prescription medications", "Still handling bills from a broken leg treatment", "Owe money for outpatient procedures",
    "Paying down debt from lab tests and scans", "Medical charges after an unexpected illness", "Dealing with old hospital debt",
    "Owe on a high deductible from last year’s care", "Paying off dental surgery bills",
    "Accumulated medical debt from chronic condition treatments", "Still paying for mental health therapy sessions",
    "Making monthly payments on a surgical bill", "Medical debt after insurance denied coverage", "Left with bills from rehab services",
    "Debt from ambulance transport and ER fees", "Paying for ongoing medication not fully covered", "Still paying back urgent care visits",
    "Covering costs from multiple doctor visits", "Owe money from past anesthesia charges", "Paying off balance from diagnostic imaging",
    "In debt from uninsured physical treatment", "Left paying bills for follow-up appointments", "Debt tied to post-surgical recovery costs",
    "Paying off overdue medical account", "Settling a hospital collection account", "Bills from a recent outpatient procedure",
    "Hospital bill from a surgery", "Outstanding dental procedure fees", "Therapy session payments", "IRS back taxes",
    "Balance due on medical imaging", "Legal fees from a custody dispute", "Emergency vet care costs", "Child support in arrears",
    "Cosmetic surgery loan", "Back rent to previous landlord", "Traffic ticket installments", "Missed utility bill payments",
    "Unpaid water service charges", "Power bill from last apartment", "Balance for chiropractic visits",
    "Internet service bill from last provider", "Past phone bill I’m still paying", "Private school tuition fees",
    "Costs from professional certification", "Language course payment plan", "Musical instrument rental balance",
    "Loan for music school enrollment", "Art class tuition still owed", "Gym membership cancellation fee", "Personal training package debt",
    "Travel expenses from family emergency", "Vacation package I’m paying off", "Wedding venue deposit debt",
    "DJ and entertainment booking fee", "Wedding photography package balance", "Costs from event catering", "Funeral costs for a relative",
    "Burial plot financing", "Cremation fee loan", "Religious donation commitment", "Church building fund loan",
    "Immigration application fees", "Citizenship paperwork charges", "Passport renewal payment", "Immigration attorney fees",
    "Back property taxes", "Local government fees", "Business startup debt", "Money borrowed to launch online store",
    "Equipment lease for side business", "Inventory purchase payments", "Overdue small business insurance", "Marketing service balance",
    "Website design payment plan", "Accountant service charges", "Consulting fee installments", "Uniform expenses for new job",
    "Job training tuition", "License renewal fees", "Conference travel I’m repaying", "Online course installment plan",
    "Workshop fees for my career", "Photography class tuition", "Travel debt from honeymoon", "Cruise payment still pending",
    "Airbnb rental balance", "Airline tickets paid on plan", "Unpaid travel insurance fees", "Pet insurance premium owed",
    "Vet dental cleaning fees", "Pet boarding charges", "Loan from a peer lending platform", "Financing from a coworking space",
    "Lease penalty for early move-out", "Furniture repair services owed", "Appliance repair debt", "HVAC maintenance balance",
    "Lawn care services payment", "Home cleaning contract fees", "Roof patch job debt", "Plumbing emergency charges",
    "Pest control service costs", "Car registration fees overdue", "Missed inspection fines", "Court fines from minor offense",
    "Judgment debt from civil case", "Loan from community organization", "Co-op membership dues", "Money owed to a club or group",
    "Missed alumni donation payments", "Local school fundraising debt", "Event planning service balance", "Balance for holiday party planner",
    "Security deposit not returned, now paying damages", "Landlord repair costs billed to me", "HOA fines for property issues",
    "Condo association dues I’m behind on", "Assessment fee for new sidewalk", "Loan for pool construction", "Balance for kitchen renovation",
    "Fence installation payment plan", "Down payment for a solar system", "Backup generator financing", "Mobile home lot fees",
    "Motorcycle insurance premiums overdue", "Boat docking fees", "Boat repair loan", "Camper storage costs", "RV park rental arrears",
    "Tax prep service loan", "Credit repair company debt", "Identity theft protection fees", "Bankruptcy filing charges",
    "Missed child care provider payments", "Camp registration I still owe", "Sports club membership debt", "Coaching session fees",
    "League participation costs", "Uniform and gear charges for a team"
  )
)

# cast free-response columns as character, then change all values to fake random values or NA
df <- df |>
  mutate(across(names(col_replacements), as.character)) |>
  mutate(across(names(col_replacements), ~ replace(.x, .x == "               ", NA))) |>
  # these values should not be repeated
  mutate(across(c("debt_other_description"), ~ replace_masked(.x, col_replacements[[cur_column()]], FALSE))) |>
  # these values can be repeated
  mutate(across(names(col_replacements)[names(col_replacements) != "debt_other_description"], ~ replace_masked(.x, col_replacements[[cur_column()]], TRUE)))

# # EXPORTING NON-GENERALIZED CODEBOOK AND DATA -----------------------------
# print(codebook(df, title = "2023 Detroit Metro Area Communities Study"), "2023 Detroit Metro Area Communities Study codebook (ARX, MST).docx")
# 
# # it's nice to have raw birth_year as numeric for the codebook, but we'll treat it as factor for the study
# df <- df |>
#   mutate(birth_year = as.factor(birth_year))
# write.csv(df, "2023 Detroit Metro Area Communities Study (ARX, MST).csv", row.names = FALSE)
# save(df, file = "2023 Detroit Metro Area Communities Study (ARX, MST).RData")


# EXPORTING GENERALIZED CODEBOOK AND DATA -----------------------------------------------------
# df <- df |>
#   mutate(birth_year = as.factor(ifelse(is.na(birth_year),
#                                        NA,
#                                        str_glue("{substr(birth_year, 1, 3)}0 to {substr(birth_year, 1, 3)}9"))))

print(codebook(df, title = "2023 Detroit Metro Area Communities Study"), "2023 Detroit Metro Area Communities Study codebook.docx")

write.csv(df, "2023 Detroit Metro Area Communities Study (MST).csv", row.names = FALSE)
save(df, file = "2023 Detroit Metro Area Communities Study (MST).RData")

# it's nice to have missing values as NA for the codebook, but we'll treat it as a separate "Missing" factor level in sdcMicro
df <- df |>
  mutate(across(!debt_other_description, ~ fct_na_value_to_level(.x, "Missing")))

write.csv(df, "2023 Detroit Metro Area Communities Study (sdcMicro).csv", row.names = FALSE)
save(df, file = "2023 Detroit Metro Area Communities Study (sdcMicro).RData")
