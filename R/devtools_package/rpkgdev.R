
# https://rpkgdev-sicss-covenant.netlify.app/intro/demo/
# https://rpkgdev-sicss-covenant.netlify.app/intro/demo/#system-setup
install.packages("available")


devtools::has_devel()

devtools::dev_sitrep()
# devtools::update_packages("devtools")
library("usethis")
usethis::git_sitrep()
# Managing Git(Hub) Credentials; 
# “Managing GitHub credentials from R, difficulty level linux”.

# Package creation
# https://rpkgdev-sicss-covenant.netlify.app/intro/demo/#package-creation
available::available("minipkg")

usethis::create_package("../minipkg")

usethis::use_git()

usethis::use_r("time"). Explain what sprintf() does.

devtools::load(), what_time()

Insert roxygen2 skeleton.

devtools::document(), ?what_time, show the Rd file.

devtools::check(), usethis::use_mit_license

add an argument, @param language blabla in docs, devtools::document(), ?what_time

usethis::use_test("current-time"): first a simple test, then a snapshot test, then a snapshot of the error.

devtools::test() / test the file on its own via the button.

devtools::check()

modify function, use_package("praise")

devtools::check()

usethis::use_readme_rmd(), write stuff

usethis::use_github() (usethis::use_github_links()). Show the GitHub repo, its description.

Build and reload (install packages from RStudio build tab), try using the package from another session. Or install from GitHub.

usethis::use_github_action_check_standard(). Check on the cloud, different operating systems.

install.packages("pkgdown"), usethis::use_pkgdown(), pkgdown::build_site(). Locally.

usethis::use_github_action("pkgdown"), change GitHub pages settings of the repo, add URL to pkgdown config and to DESCRIPTION.

usethis::use_release_issue() for information

