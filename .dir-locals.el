((nil . ((eval . (setq-local
                  org-roam-directory (f-join (f-full (locate-dominating-file
                                                      default-directory ".dir-locals.el"))
                                             "org-notes")
                  org-roam-db-location (expand-file-name "org-roam.db"
                                                         org-roam-directory))))))
