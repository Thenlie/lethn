---
name: blog
---
Tasks for this directory. Add one with: clask add "Title"
Format: https://github.com/Thenlie/clask#format

---
id: create-github-pages-publishing-action
title: Create github pages publishing action
priority: 3
status: todo
created: 2026-11-16
---

---
id: link-github-pages-deployment-to-lethn
title: link github pages deployment to lethn.com domain
priority: 3
status: todo
created: 2026-11-19
---

---
id: set-site-url-in-build-sh-to-https-lethn
title: Set SITE_URL in build.sh to https://lethn.com
priority: 3
status: done
created: 2026-11-25
completed: 2026-11-25
---
build.sh:15 still has placeholder https://USERNAME.github.io/blog, so feed.xml links are wrong. Set once custom domain is live.

---
id: add-static-cname-for-lethn-com
title: Add static/CNAME for lethn.com
priority: 3
status: todo
created: 2026-11-25
---
static/CNAME containing lethn.com, plus DNS records at registrar. Without it, deploys can reset the Pages custom domain.

---
id: add-links-from-landing-page-to-posts-and
title: Add links from landing page to posts and feed
priority: 3
status: done
created: 2026-11-25
completed: 2026-11-25
---
home/index.html shows only the title; no way to reach posts/index.html or feed.xml.
