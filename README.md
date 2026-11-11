# blog

Static blog. Articles are LaTeX, converted to HTML (with MathML for math) by
Pandoc at build time. No JavaScript, no framework. Only dependency: Pandoc.

## Add a post

1. Create `posts/<slug>.tex` with at least:
   ```latex
   \documentclass{article}
   \title{Post Title}
   \date{2026-11-11}        % must be YYYY-MM-DD; used for sorting
   \begin{document}
   \maketitle
   ...
   \end{document}
   ```
2. Commit and push to `main`. GitHub Actions builds and deploys.

The URL is `posts/<slug>.html`. The filename is the slug; a date prefix is
optional and not parsed.

## Drafts

Put unfinished posts in `drafts/`. They are not built. `git mv` to `posts/`
to publish.

## Images

Put files in `posts/img/` and reference them as
`\includegraphics{img/figure.svg}`. The folder is copied to
`public/posts/img/`.

Pandoc does not render TikZ or pgfplots. Compile those to SVG separately
(`pdflatex` + `dvisvgm` or `pdf2svg`) and include the SVG.

## Preview locally

```sh
./build.sh
open public/index.html
```

Relative links are used everywhere, so the site works from `file://`, from
the GitHub Pages subpath, and from a custom domain root without changes.

## Layout

```
posts/          published .tex articles
posts/img/      images
drafts/         not built
static/         copied as-is to public/ (style.css, favicon, CNAME)
template.html   the one Pandoc HTML template (header, nav, footer)
build.sh        the whole build
public/         generated output, git-ignored
```

## First deploy

1. Create a GitHub repo and push `main`.
2. Repo Settings → Pages → Source: **GitHub Actions**.
3. Edit `SITE_URL` in `build.sh` to `https://<user>.github.io/<repo>`.

## Custom domain

1. Add `static/CNAME` containing the domain (e.g. `blog.example.com`).
2. Change `SITE_URL` in `build.sh` to `https://blog.example.com`.
3. Point DNS: `CNAME blog.example.com -> <user>.github.io`.
4. Repo Settings → Pages → Custom domain, enable HTTPS.
