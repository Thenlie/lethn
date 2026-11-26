#!/usr/bin/env bash
# Build the whole site into public/.
#
#   ./build.sh
#
# Requires only pandoc. Posts are posts/*.tex, each with \title{...} and
# \date{YYYY-MM-DD}. Anything in drafts/ is ignored.
set -euo pipefail
cd "$(dirname "$0")"

# Let \usepackage{photos} in a post find posts/photos.sty (Pandoc searches TEXINPUTS).
export TEXINPUTS="posts:${TEXINPUTS:-}"

SITE_TITLE="LETHN"
SITE_URL="https://lethn.com"   # no trailing slash

# --- 1. Fresh output dir, copy static assets ---------------------------------
rm -rf public
mkdir -p public/posts
cp -R static/. public/
cp home/home.css public/    # landing page; index.html is filled in at step 3
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
    --lua-filter=wrapfig.lua \
    --template=template.html \
    -V root=../ -V sitetitle="$SITE_TITLE" \
    -o "public/posts/$slug.html"

  printf '%s\t%s\t%s\n' "$date" "$slug" "$title" >> "$list"
done

# Newest first. ISO dates sort correctly as plain text.
sort -r "$list" -o "$list"

xml_escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }

# --- 3. Landing page: post list into the sidebar of home/index.html ----------
# Each post becomes an <li> in place of the <!-- POSTS --> marker line.
sidebar=$(mktemp)
while IFS=$'\t' read -r date slug title; do
  printf '      <li><a href="posts/%s.html">%s</a><time datetime="%s">%s</time></li>\n' \
    "$slug" "$(printf '%s' "$title" | xml_escape)" "$date" "$date"
done < "$list" > "$sidebar"
awk 'NR==FNR { items = items $0 "\n"; next }
     /<!-- POSTS -->/ { printf "%s", items; next }
     { print }' "$sidebar" home/index.html > public/index.html

# --- 4. Post list (posts/index.html) -----------------------------------------
index=$(mktemp)
while IFS=$'\t' read -r date slug title; do
  printf -- '- <time datetime="%s">%s</time> [%s](%s.html)\n' "$date" "$date" "$title" "$slug"
done < "$list" > "$index"

pandoc "$index" -f markdown -s \
  --template=template.html \
  -M title="$SITE_TITLE" -V root=../ -V sitetitle="$SITE_TITLE" -V is_index=true \
  -o public/posts/index.html

# --- 5. Atom feed ------------------------------------------------------------
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

# --- 6. Feed page (feed.html) ------------------------------------------------
# Browsers show raw Atom as an XML tree, so the nav links here instead.
pandoc -f markdown -s \
  --template=template.html \
  -M title="Feed" -V root= -V sitetitle="$SITE_TITLE" \
  -o public/feed.html <<EOF
Subscribe in a feed reader with this address:

\`$SITE_URL/feed.xml\`

[View the raw feed](feed.xml).
EOF

echo "Built $(wc -l < "$list" | tr -d ' ') post(s) -> public/"
rm -f "$list" "$index" "$sidebar"
