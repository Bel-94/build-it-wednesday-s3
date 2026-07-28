# Screenshots guide

Use these images in your README, LinkedIn post, and interview walkthrough.

## What you already have (core set)

| File | What it proves |
| --- | --- |
| `terraform-apply.png` | Infrastructure as Code worked end-to-end (`Apply complete` + outputs) |
| `home-page.png` | The public website is reachable from the S3 website URL |
| `how-objects-are-listed.png` | Website files exist in the bucket as objects/keys |

That trio is enough for a solid portfolio demo.

### Quick quality check

- **terraform-apply.png** — ideally shows `Apply complete!` and the `website_url` output  
- **home-page.png** — address bar shows the `s3-website-...amazonaws.com` URL (proves S3 hosting, not a local file)  
- **how-objects-are-listed.png** — shows keys like `index.html`, `styles.css`, `assets/...`

## Optional extras (nice for LinkedIn / deeper teaching)

Take these only if you want a richer story:

| Suggested name | Capture this | Why it helps |
| --- | --- | --- |
| `terraform-plan.png` | `terraform plan` summary (`Plan: X to add...`) | Shows you review changes before apply |
| `bucket-website-config.png` | Console or CLI: index/error document settings | Explains Static Website Hosting |
| `bucket-policy.png` | Public `s3:GetObject` policy (redact account IDs if needed) | Teaches least-privilege public read |
| `error-page.png` | Visit a fake path like `/does-not-exist` | Proves `error.html` works |
| `architecture-diagram.png` | Already in `../architecture/` | Use in posts; no need to duplicate |

## What not to screenshot

- Access keys, secret keys, or full IAM credentials  
- Account root email / billing details  
- Personal phone numbers or unrelated desktop clutter  

Crop tightly to the terminal/browser/console area.

## How to use them

**README:** add an optional “Deployment evidence” section with 2–3 images.  
**LinkedIn:** home page + terraform apply side by side works best.  
**Interview:** walk through apply → objects → live URL in that order.

## Suggested talking order

1. Terraform apply (IaC created the resources)  
2. Objects listed in the bucket (files uploaded as object keys)  
3. Browser home page (public website endpoint works)
