---
name: meeting-notes
description: Structure meeting notes into agenda, decisions, and action items. Use when the user asks for meeting minutes, standup notes, or follow-up tracking.
license: MIT
source: plugin
compatibility: Requires read_file and read_skill; ask_user optional for clarifying owners/dates
metadata:
  author: danqing
  version: "0.1.0"
  category: work
---

# Meeting Notes

Turn rough discussion notes into a clear, actionable record.

## Workflow

1. **Collect context** — meeting title, date, attendees, and raw notes (chat paste, transcript, or bullets).
2. **Clarify gaps** — if owners or due dates are missing for action items, ask once (prefer multiple choice).
3. **Structure** — follow `references/notes-template.md`:
   - Agenda / topics covered
   - Decisions (what was agreed)
   - Action items (owner + due date when known)
   - Open questions
4. **Deliver** — output the filled template in markdown. Keep wording faithful to the source; do not invent decisions.

## Anti-patterns

- Mixing decisions with action items without owners
- Omitting attendees or date when available
- Expanding scope beyond what was actually discussed
