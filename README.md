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

Captioned photo, full width:
```latex
\begin{figure}[!htbp]
  \centering
  \includegraphics[width=\linewidth]{img/post/photo.jpg}
  \caption{Caption text.}
\end{figure}
```

Framed photo layouts live in `posts/photos.sty`. Load it in the preamble,
after `caption`, with `\usepackage{photos}`. `wrapfig.lua` and
`static/style.css` give the HTML the same layouts and frame.

Framed photo the text flows around. Put it right before the paragraph it
should wrap:
```latex
\begin{wrapphoto}{r}   % l or r; optional width, e.g. \begin{wrapphoto}[0.40]{l}
  \includegraphics[width=\linewidth]{img/post/photo.jpg}
  \caption{Caption text.}
\end{wrapphoto}
Paragraph text starts here, no blank line above.
```

Framed row of photos with one caption:
```latex
\begin{photopair}
  \includegraphics[width=0.49\linewidth]{img/post/a.jpg}\hfill
  \includegraphics[width=0.49\linewidth]{img/post/b.jpg}
  \caption{Caption text.}
\end{photopair}
```

Full-bleed banner across the top of page 1 (no frame), right before
`\maketitle`. Tune with `\setlength{\bannerheight}{42mm}` and
`\renewcommand{\bannerfocus}{0.5}` (0 keeps the top, 1 the bottom):
```latex
\begin{banner}
  \includegraphics[width=\linewidth]{img/post/banner.jpg}
\end{banner}
```

Shrink phone photos before committing (and strip metadata):
```sh
sips -Z 1600 -s format bmp IMG.HEIC --out tmp.bmp
sips -s format jpeg -s formatOptions 80 tmp.bmp --out posts/img/post/photo.jpg
```

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
home/           landing page, copied as-is to public/ (index.html, home.css)
static/         copied as-is to public/ (style.css, favicon, CNAME)
template.html   the one Pandoc HTML template for posts + post list (posts/index.html)
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
