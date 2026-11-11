#!/usr/bin/env bash
# Build the whole site into public/.
#
#   ./build.sh
#
# Requires only pandoc. Posts are posts/*.tex, each with \title{...} and
# \date{YYYY-MM-DD}. Anything in drafts/ is ignored.
set -euo pipefail
cd "$(dirname "$0")"

SITE_TITLE="My Blog"
SITE_URL="https://USERNAME.github.io/blog"   # no trailing slash; change once for a custom domain

# --- 1. Fresh output dir, copy static assets ---------------------------------
rm -rf public
mkdir -p public/posts
cp -R static/. public/
[ -d posts/img ] && cp -R posts/img public/posts/

# --- 2. Render each post, collect "date<TAB>slug<TAB>title" ------------------
list=$(mktemp)
for f in posts/*.tex; do
  [ -e "$f" ] || continue   # no posts yet
  slug=$(basename "$f" .tex)

  # --quiet: the plain-text writer warns about math it can't render as text; irrelevant here.
  meta=$(pandoc "$f" --quiet -t plain --template=<(printf '$title$\t$date$'))
  title=${meta%%$'\t'*}
  date=${meta#*$'\t'}

  if [[ ! "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "ERROR: $f needs \\date{YYYY-MM-DD} (got '$date')" >&2
    exit 1
  fi
  if [ -z "$title" ]; then
    echo "ERROR: $f needs \\title{...}" >&2
    exit 1
  fi

  # shift-heading-level: \section -> <h2>, since <h1> is the post title.
  pandoc "$f" -s --math-method=mathml --shift-heading-level-by=1 \
    --template=template.html \
    -V root=../ -V sitetitle="$SITE_TITLE" \
    -o "public/posts/$slug.html"

  printf '%s\t%s\t%s\n' "$date" "$slug" "$title" >> "$list"
done

# Newest first. ISO dates sort correctly as plain text.
sort -r "$list" -o "$list"

# --- 3. Index page -----------------------------------------------------------
index=$(mktemp)
while IFS=$'\t' read -r date slug title; do
  printf -- '- <time datetime="%s">%s</time> [%s](posts/%s.html)\n' "$date" "$date" "$title" "$slug"
done < "$list" > "$index"

pandoc "$index" -f markdown -s \
  --template=template.html \
  -M title="$SITE_TITLE" -V root=./ -V sitetitle="$SITE_TITLE" -V is_index=true \
  -o public/index.html

# --- 4. Atom feed ------------------------------------------------------------
xml_escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
newest=$(head -1 "$list" | cut -f1)
{
  printf '<?xml version="1.0" encoding="utf-8"?>\n'
  printf '<feed xmlns="http://www.w3.org/2005/Atom">\n'
  printf '  <title>%s</title>\n' "$(printf '%s' "$SITE_TITLE" | xml_escape)"
  printf '  <link href="%s/"/>\n' "$SITE_URL"
  printf '  <link rel="self" href="%s/feed.xml"/>\n' "$SITE_URL"
  printf '  <id>%s/</id>\n' "$SITE_URL"
  printf '  <updated>%sT00:00:00Z</updated>\n' "${newest:-1970-01-01}"
  while IFS=$'\t' read -r date slug title; do
    url="$SITE_URL/posts/$slug.html"
    printf '  <entry>\n'
    printf '    <title>%s</title>\n' "$(printf '%s' "$title" | xml_escape)"
    printf '    <link href="%s"/>\n' "$url"
    printf '    <id>%s</id>\n' "$url"
    printf '    <updated>%sT00:00:00Z</updated>\n' "$date"
    printf '  </entry>\n'
  done < "$list"
  printf '</feed>\n'
} > public/feed.xml

rm -f "$list" "$index"
echo "Built $(ls public/posts/*.html 2>/dev/null | wc -l | tr -d ' ') post(s) -> public/"
