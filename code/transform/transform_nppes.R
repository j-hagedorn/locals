

#****************************************************#
# This script assumes fetch_nppes.R was already run
#****************************************************#



# downloading taxonomy health crosswalk  from the National Uniform Claim Committee 
taxonomy<-read_csv("https://www.nucc.org/images/stories/CSV/nucc_taxonomy_201.csv")%>%
  rename(taxonomy_code = Code, taxonomy_group = Grouping, 
         taxonomy_classification = Classification, taxonomy_specialization = Specialization
         ,taxonomy_desc = Definition)%>%
  distinct()



#===============================================================================#
# Taking only a subset of variables and joining tax codes and hierarchy ====
#===============================================================================#


nppes_sub <- 
  nppes %>%
  filter(`Entity Type Code` == 2,
         is.null(`NPI Deactivation Reason Code`)==F
         ) %>%
  mutate( npi = as.character(NPI),
          #NPPES_NPI = NPI,
          #      mail_ca1 =`Provider First Line Business Mailing Address`,
          #      mail_ca2 =`Provider Second Line Business Mailing Address`,
          #      mail_city =`Provider Business Mailing Address City Name`,
          #      mail_st = `Provider Business Mailing Address State Name`,
          #      mail_zip=`Provider Business Mailing Address Postal Code`,
          provider_name = `Provider Organization Name (Legal Business Name)`,
          other_name = `Provider Other Organization Name`,
          CA_ADDR1 = `Provider First Line Business Practice Location Address`,
          CA_ADDR2 = `Provider Second Line Business Practice Location Address`,
          CA_CITY = `Provider Business Practice Location Address City Name`,
          CA_STATE =`Provider Business Practice Location Address State Name`,
          CA_ZIP = `Provider Business Practice Location Address Postal Code`,
  ) %>%
  select(npi,
         provider_name,
         other_name,
         CA_ADDR1,
         CA_ADDR2,
         CA_CITY,
         CA_STATE,
         CA_ZIP,
         npi_assign_date = `Provider Enumeration Date`,
         last_npi_update_date = `Last Update Date`,
         npi_deactivation_date = `NPI Deactivation Date`,
         npi_reactivation_date = `NPI Reactivation Date`,
         taxonomy = `Healthcare Provider Taxonomy Code_1`,
         taxonomy_2 = `Healthcare Provider Taxonomy Code_2`,
         license_number = `Provider License Number_1`, 
         license_number_2 = `Provider License Number_2`,
         sole_proprietor = `Is Sole Proprietor`,
         organization_subpart = `Is Organization Subpart`,
         gender = `Provider Gender Code`,
         other_provider_type =  `Other Provider Identifier Type Code_1`,
         contact = `Authorized Official Telephone Number`,
         vald_date = `Last Update Date`
         
  )%>%
  left_join(taxonomy, by = c("taxonomy" = "taxonomy_code"))


#====================================================================#
# Formatting addresses for to make geo-coding with Google ideal =====
#====================================================================#

nppes_sub <-
  nppes_sub %>%
  mutate( # make everything lowercase
    street = str_squish(str_to_lower(CA_ADDR1)),
    city = str_squish( str_to_lower(CA_CITY)),
    st = str_squish(str_to_lower(CA_STATE)),
    zip = str_squish( str_sub(CA_ZIP,1,5)),
    sup = str_squish(str_to_lower(CA_ADDR2))  ,
    # Trying to standardize street names. Because  they are 
    # in the supplemental address fields, I gotta do it twice. 
    street = str_replace_all(street,pattern = "Street|street|St.|st.",
                             replacement =  "st."),
    street = str_replace_all(street,pattern = "rd.|Rd.|Road|road",
                             replacement =  "rd."),
    
    sup = str_replace_all(sup,pattern = "rd.|Rd.|Road|road",
                          replacement =  "rd."),
    sup = str_replace_all(sup,pattern = "Street|street|St.|st.",
                          replacement =  "st.")
  )%>%
  mutate(
    
    # if the first characters of street are numbers, use that, otherwise use the sup
    # field. Sometimes they will put the street addresses in the AFC column
    # and this helps recify that issue
    street2 = case_when(str_detect(substring(street, 1, 1),'[0-9]') == TRUE ~ street,
                        TRUE~ sup), 
    
    # Often times they will place the street address into the sup column right after
    # the name of the AFC. This creates a new column that parses out when they begin 
    # typing a street address. 
    street_from_name =  str_remove(street, fixed(sub( "[0-9].*$", "", street))),
    
    # Now when the street2 does not have a numbered street to start I'll replace with 
    # the street address found pressed next to the name of the AFC
    
    street3 = coalesce(street2,street_from_name),
    
    
    EncAddress = str_squish(paste(street3,",",city,",",st," ",zip,",","usa",sep = "")),
    EncAddress = str_replace_all(EncAddress ,pattern = "NA,",
                                 replacement =  ""),
    
    EncAddress  = case_when(str_detect(substring(EncAddress, 1, 1),',') == TRUE ~ 
                              paste(street_from_name, EncAddress,sep = ""),
                            TRUE~ EncAddress),
    
    EncAddress  = case_when(str_detect(substring(EncAddress, 1, 1),',') == TRUE ~ 
                              paste(street, EncAddress,sep = ""),
                            TRUE~ EncAddress)
    
  )%>%
  mutate(EncAddress = str_squish(EncAddress),
         state = CA_STATE)%>%
  select(npi,provider_name,other_name,npi_assign_date,npi_deactivation_date,npi_reactivation_date,
         taxonomy,taxonomy_2,license_number,license_number_2,taxonomy_group,sole_proprietor,organization_subpart,
         gender,other_provider_type,
         taxonomy_classification,taxonomy_specialization,taxonomy_desc,
         npi_practice_address = EncAddress,state,contact,vald_date)



#==============================#
# Writing to the database ====
#==============================#

# reestablishing connection 
locals_db <- DBI::dbConnect(odbc::odbc(), "locals")


nppes_sub_minus_desc<-nppes_sub%>%
  select(-taxonomy_desc)

#dbSendQuery(con_mshn_bi, "TRUNCATE TABLE mshn_bi.[dbo].[npi_locations]")

dbCreateTable(locals_db,'npi_org_locations', nppes_sub_minus_desc)

dbWriteTable(locals_db, 'npi_org_locations', nppes_sub_minus_desc, overwrite = T)
