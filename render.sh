#!/bin/bash

# Parse parameters (https://www.brianchildress.co/named-parameters-in-bash/)
mailout_type=${mailout_type:-issue}
year=${year:-$(date +%Y)}
issue=${issue}

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        param="${1/--/}"
        declare $param="$2"
        # echo $1 $2 // Optional to see the parameter:value result
   fi

  shift
done


if [ $mailout_type = issue ]
then
  if [ -z $issue ]
  then
    echo "Error: Set --issue parameter" && exit 1
  fi

  http "https://labanimalsjournal.ru/api/v1/articles/$year/$issue" | jq > articles.json && \
  jinja2 templates/issue.html articles.json \
    --format=json \
    -e jinja-extensions.typograph.TypographExtension \
    -e jinja2_markdown.MarkdownExtension \
    > tmp.mjml && \
  ./node_modules/.bin/mjml \
    --config.minify true \
    --config.minifyOptions='{"minifyCSS": true}' \
  tmp.mjml > laj-$year-$issue.html && \
  rm tmp.mjml articles.json

fi
