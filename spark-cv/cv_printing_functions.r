print_research <- function(name) {
    research %>% 
    filter(type == name) %>% 
    arrange(order) %>% 
    mutate(fa_web = ifelse(!is.na(website), 
                            paste0( '<a href=', 
                                    website, 
                                    '><i class="fas falink fa-globe"></i></a>'),
                            ""),
            fa_git = ifelse(!is.na(repo), 
                            paste0('<a href=', 
                                    repo, 
                                    '><i class="fab fafooter fa-github"></i></a>'),
                            ""),
            fa_youtube = ifelse(!is.na(youtube), 
                            paste0('<a href=', 
                                    youtube, 
                                    '><i class="fab fa-youtube"></i></a>'),
                            ""),
            tool = ifelse(!is.na(tool),
                            paste0(
                            "<span style='background-color:#b6d2db; color:white;border-radius:4px; padding-right:2px;padding-left:2px;'>",
                            tool,
                            "</span>"
                            ),
                            ""),
            year = str_c(year_begin, 
                        " --- ", 
                        ifelse(is.na(year_end), "current", year_end)),
            what = paste0(what, ". ", "(",  year, "). ", tool, 
                            fa_git, fa_web, fa_youtube),
            what = gsub("NA, ", "", what),
            order = paste0(order, ".")
            ) %>% 
    select(point, what) %>% 
    kable()
}

