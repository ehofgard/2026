---
layout: page
title: submitting
permalink: /submitting/
description:
nav: true
nav_order: 3
---

## How to Submit to the GRaM Blogpost Track

The GRaM Blogpost–Tutorial track follows an **open, GitHub-based submission process**, designed to reduce friction for authors and reviewers while preserving a double-blind review standard.

---

### Review model and anonymity

Submissions **must be anonymized for review**.  
Authors submit their blog posts via a **GitHub pull request** to the [GRaM blog 2026 Repo](https://github.com/gram-blogposts/2026).

<!-- Each pull request automatically builds and deploys the post to a **temporary public URL**, which reviewers use to read and evaluate the submission. -->

Reviewers are instructed **not to inspect git history or repository metadata**, which may reveal author identity. This process is no less double-blind than reviewing papers already available on public preprint servers, a standard practice in machine learning.

Authors who require stricter anonymity may submit from a **new GitHub account without identifying information**, used exclusively for this track.

---

### Submission template and infrastructure

The GRaM blog uses the **al-folio** Jekyll template, with automated builds handled by **GitHub Actions** and Docker.

Submissions are validated automatically.  
**Any deviation from the required file structure will cause the submission to be rejected**, so please follow the instructions carefully.

---

### Quick submission overview

1. **Fork or download the [GRaM blog 2026 Repo](https://github.com/gram-blogposts/2026).**
2. **Create a single blog post**, anonymized for review:
   - A Markdown file in `_posts/` named  
     `YYYY-MM-DD-[submission-name].md`
   - Static images in  
     `assets/img/YYYY-MM-DD-[submission-name]/`
   - Interactive HTML (optional) in  
     `assets/html/YYYY-MM-DD-[submission-name]/`
   - References in  
     `assets/bibliography/YYYY-MM-DD-[submission-name].bib`
3. **Do not modify any other files.**
4. **Preview locally** using the provided devcontainer (recommended).
5. **Open a pull request** to the main branch:
   - The PR title must exactly match the submission name.
6. The automated pipeline will:
   - verify the file structure,
   - deploy the post to a public preview URL,
   - report the URL in the pull request.
7. **Register the submission on OpenReview**, including the preview URL.

Updates must be made by **editing the existing pull request**, not by opening a new one.

---

### File structure (strictly enforced)

Your submission must introduce **only** the following files:

_posts/
YYYY-MM-DD-[submission-name].md
assets/
bibliography/
YYYY-MM-DD-[submission-name].bib
img/
YYYY-MM-DD-[submission-name]/
html/
YYYY-MM-DD-[submission-name]/

The `YYYY-MM-DD-[submission-name]` identifier **must be identical across all files and folders**.

---

### Post format

Each post must:
- Use the `distill` template, 
- include a clear title,
- include a short abstract in the `description` field (2–3 sentences, no LaTeX or links),
- include a table of contents,
- list authors as `Anonymous` during review.

Author information must be added **only after acceptance**, for the camera-ready version.

<!--
### Reviewing and acceptance


Reviewers evaluate submissions **only via the deployed preview website**, not via repository contents. Accepted posts will be merged into the main site after the review period.
-->

---

### Camera-ready

Detailed camera-ready instructions, including de-anonymization, will be provided after acceptance decisions are released.

---

###

Feel free to reach out to the organizers at:
organizers [at] gram-workshop [dot] org
manuel.lecha [at] iit.it
