# Hackathon setup (Terac Zero Human Company)

Run this on the laptop that will collect payments. It opens Stripe and Terac, writes `.env`, and saves the organizer packet.

```bash
./bin/hackathon-setup
```

Do **not** commit `.env` or `tmp/hackathon-organizer.env`.

## What organizers need

From `tmp/hackathon-organizer.env`, submit only:

1. Team name
2. Payment Link URL (`https://buy.stripe.com/...`)
3. Restricted key (`rk_...`) — Balance + Charges **Read**, everything else **None**

Never share `sk_`.

## What the app does with those values

| Value | Effect |
| --- | --- |
| `STRIPE_PAYMENT_LINK_URL` | Every charge uses this same link (guidebook rule). |
| `TERAC_API_KEY` | Live Terac. Before rebooking, a **General Population** study picks copy A vs B. Dashboard shows before/after. Injury questions still escalate to a human. |
| `DEMO_MODE=false` | Set by the wizard once the payment link is saved. |
| `RENDER_API_KEY` + `RENDER_TASK_SLUG` | **Run my business** starts a Render Workflow. The workflow calls `POST /internal/runs`. |

Restart the server after the wizard so `.env` loads. Copy the same non-secret and secret values onto the Render web service (`STRIPE_PAYMENT_LINK_URL`, `TERAC_API_KEY`, `DEMO_MODE=false`, and the Render Workflow vars if you use them).

## Render Workflows (Best use of Render)

Blueprints cannot create Workflows. Create one in the Dashboard: repo `kewinzaq1/operator`, root directory `workflows`, start command `python main.py`. Details in [`workflows/README.md`](workflows/README.md).

## Demo video (2:00)

File: [`demo/operator-2min.mp4`](demo/operator-2min.mp4) — 1920×1080, voiceover, exactly two minutes.

Covers the morning leak, Run my business, Marta/Stripe, Piotr, Terac general-population before/after, Kasia, lead + reviews, Wojtek expert hire, impact.

Preview the film in a browser: open `public/demo-film.html` or re-record with `./bin/record-demo`.

## Prize tracks we already hit without extra setup

- **Terac (required):** GP copy test + expert escalation, before/after on the dashboard
- **Stripe (Agent-Run Company):** personal Payment Link on every checkout
- **Render:** web service Blueprint + optional Workflows runner
