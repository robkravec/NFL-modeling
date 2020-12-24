NFL_modeling.html: NFL_modeling.Rmd data/nfl-big-data-bowl-2021.zip
	Rscript -e "rmarkdown::render('NFL_modeling.Rmd')"

data/nfl-big-data-bowl-2021.zip: 
	mkdir -p $(@D)
	cd $(@D); kaggle competitions download -c nfl-big-data-bowl-2021
	
clean_data:
	rm -rf data/
	
clean_html:
	rm NFL_modeling.html
	
.PHONY: clean_data; clean_html