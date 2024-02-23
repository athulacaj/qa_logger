#!/bin/bash

# Read the HTML file
html_content=$(cat ./supporting/_support.html)
css_content=$(cat ./supporting/_support.css)
js_content=$(cat ./supporting/_support.js)



# Use printf instead of echo -e
printf "final String htmlString = r'''%s''';" "$html_content" > build/output_html.dart
printf "final String cssString = r'''%s''';" "$css_content" > build/output_css.dart
printf "final String jsString = r'''%s''';" "$js_content" > build/output_js.dart