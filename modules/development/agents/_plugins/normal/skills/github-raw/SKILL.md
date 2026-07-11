---
name: github-raw
description: Use when the user wants to fetch, view, read, or look up a file on GitHub or GitLab via a URL. Transforms URLs to raw URLs to avoid downloading full HTML pages.
---

# Raw URL Fetcher for GitHub and GitLab

When the user provides a URL pointing to a file on GitHub or GitLab, convert it to a raw URL before fetching.

## GitHub

URLs containing `/blob/`:

1. Replace `github.com` with `raw.githubusercontent.com`
2. Remove the `/blob/` segment

Example:
- Input:  `https://github.com/owner/repo/blob/main/src/index.ts`
- Output: `https://raw.githubusercontent.com/owner/repo/main/src/index.ts`

## GitLab

URLs containing `/-/blob/`:

1. Replace `/-/blob/` with `/-/raw/`

Example:
- Input:  `https://gitlab.com/owner/repo/-/blob/main/src/index.ts`
- Output: `https://gitlab.com/owner/repo/-/raw/main/src/index.ts`

## Instructions

- Always use `WebFetch` with the transformed raw URL to retrieve plain text content.
- Do NOT fetch the original URL — it returns a full HTML page.
