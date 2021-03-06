### Local variables ###
LOCAL_SERVER_PORT=4000
BASE_URL="/blog"

### Start by cleaning the site output directory first ###
bundle exec jekyll clean

### Launch Chrome at the local URL ###
open -a /Applications/Google\ Chrome.app http://localhost:$LOCAL_SERVER_PORT$BASE_URL/

### Start Jekyll with custom configuration ###
bundle exec jekyll serve --strict_front_matter --port $LOCAL_SERVER_PORT --baseurl $BASE_URL --livereload --drafts
