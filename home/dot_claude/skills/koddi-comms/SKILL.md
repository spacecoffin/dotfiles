---
name: koddi-comms
description: Write high-engagement Slack updates optimized for Koddi's communication patterns. Use when asked to write project updates, weekly updates, launch announcements, status reports, OKR updates, standups, handoffs, escalations, or any team communication intended for Slack. Drives replies, reactions, and accountability.
---

# Koddi Comms

Write status updates optimized for engagement and action.

Before drafting, proactively gather live context from MCP sources (Step 0) unless the user has already provided sufficient raw input.

---

## Step 0: Gather Context from MCP Sources

Pull live data in parallel before drafting. Use the table below to decide which sources to query based on the update type.

| Update Type | Krisp | Granola | Linear | Slack |
|-------------|-------|---------|--------|-------|
| Weekly/Sprint | ✅ recent meetings | ✅ this week | ✅ issues + projects | ✅ channel pulse |
| Standup | ✅ action items | ✅ yesterday's meetings | ✅ my issues | — |
| OKR / Board | — | ✅ executive meetings | ✅ all projects | — |
| Project Status | ✅ project meetings | ✅ project meetings | ✅ project issues | ✅ project channel |
| Launch | ✅ launch meetings | ✅ launch meetings | ✅ project milestones | ✅ launch channel |
| Handoff | ✅ upcoming meetings | ✅ recent notes | ✅ my open issues | — |
| Escalation | ✅ relevant meetings | ✅ relevant notes | ✅ relevant issues | ✅ relevant threads |

**Always run these in parallel.** Only skip a source if it clearly doesn't apply.

### Krisp
Pull meeting summaries, decisions, and action items from recorded calls.

```
# Pending action items (your open tasks from meetings)
list_action_items(completed: false, limit: 20)

# Recent meeting summaries (last 7 days)
search_meetings(after: "<7-days-ago>", fields: ["name", "date", "meeting_notes", "action_items"])

# For deep dive: get full transcript of a specific meeting
get_document(documentId: "<meeting_id>")

# Upcoming meetings (for handoffs or prep context)
list_upcoming_meetings(days: 7)
```

**Extract:** decisions made, action item owners + dates, blockers raised, shipped items called out
**Ignore:** intros, "can you hear me", restated context, small talk

### Granola
Richer structured notes — use for executive/cross-functional meetings where Granola was active.

```
# Natural language query (best for open-ended context)
query_granola_meetings(query: "status updates blockers decisions this week")

# List recent meetings then drill in
list_meetings(time_range: "this_week")   # or "last_week"
get_meetings(meeting_ids: ["<id1>", "<id2>"])

# Full transcript for exact quotes
get_meeting_transcript(meeting_id: "<id>")
```

**Extract:** key decisions, action items with owners, project health signals, named blockers
**Prefer over Krisp** for: exec syncs, cross-functional reviews, external meetings

### Linear
Pull live issue and project status — ground truth for engineering/product work.

```
# My active issues
list_issues(assignee: "me", state: "In Progress")

# Issues updated recently on a project
list_issues(project: "<project name>", updatedAt: "-P7D", state: "In Progress")

# Project health with milestones
list_projects(member: "me", includeMilestones: true, includeMembers: true)

# All projects for OKR/board updates
list_projects(includeArchived: false, includeMilestones: true)
```

**Extract:** issue status (in progress / blocked / done), milestone dates, completion %, owners
**Map to update language:** "In Progress" → 🔨, "Done" → ✅/🚀, "Blocked" → ⚠️ or 🔴

### Slack
Pull recent channel activity for pulse checks and missed context.

```
# Search across channels for a topic
slack_search_public(query: "<topic> after:YYYY-MM-DD", sort: "timestamp")

# Read a specific project/team channel
slack_search_channels(query: "<project or team name>")
slack_read_channel(channel_id: "<C...>", limit: 50, response_format: "concise")

# Search for decisions or blockers in a channel
slack_search_public(query: "blocked decision shipped in:<channel-name> after:YYYY-MM-DD")
```

**Extract:** ✅/🚀 reactions as shipped signals, @mentions with asks, stated blockers, decisions in threads
**Ignore:** bot noise, +1 replies, general chatter without action

### Synthesize Before Drafting

After gathering, reconcile across sources:
- **Deduplicate**: same item may appear in Granola notes + Linear issue + Slack thread — pick the most specific/recent
- **Resolve conflicts**: if Slack says "shipped" but Linear still shows "In Progress", flag or use the more recent signal
- **Fill gaps**: if a blocker or owner is missing, flag as TBD rather than inventing
- **Prioritize recency**: newer data wins; note if information is older than 48h

---

## Slack Output Format

Apply these rules when rendering any update for Slack.

**Emoji**: Use Slack emoji codes, not Unicode. `:large_green_circle:` not 🟢, `:warning:` not ⚠️, `:trident:` not 🔱, etc.

**Title line**: Plain text flanked by the relevant emoji — no markdown bold or italic.
```
:trident: Triton Project Update :trident:
```

**Date**: Plain text on its own line directly below the title. No formatting.

**Section headers**: Bold using `*Header*`. E.g., `*Status by Workstream*`, `*Next Milestone*`.

**Sub-points within a bullet**: Use line breaks only when it meaningfully aids readability — e.g., 3+ sub-items that would be unwieldy on one line. Otherwise keep on one line with semicolons.

**Footer**: Plain parentheses — `(details in thread)`. No italic, no formatting.

**No leading spaces** on any line.

---

## Step 1: Clarify Audience

If not specified, ask: **"Who's the audience for this update?"**

| Audience | Template |
|----------|----------|
| Board / leadership (cross-initiative) | OKR Update |
| Execs / stakeholders (project-level) | Project Status Update |
| Team (weekly rhythm) | Weekly/Sprint Update |
| Team (daily rhythm) | Async Standup |
| Ops / support | Queue Pulse Check |
| Shipping news | Launch Announcement |
| Needs a decision | Escalation Thread |
| Going OOO / transitioning | Handoff Update |

## Step 2: Extract Signal from Input

Status updates are often synthesized from messy sources.

**What to extract:**
- State changes — shipped, broke, blocked, started
- Commitments — dates, milestones, owners
- Blockers — waiting, dependent, at risk

**What to ignore:** pleasantries, restated context, filler, tangents

| Source | Signal | Noise |
|--------|--------|-------|
| Slack threads | ✅/🚀 reactions; "shipped", "blocked"; @mentions with asks | "thanks"; side chatter |
| Call transcripts | "Action item:", "Who owns?", decisions, blockers | "Can you hear me?", intros |
| Context dumps | Dates, owners, statuses, dependencies | Background, duplication |
| Krisp action items | `completed: false` items with assignee + due date | Completed items (unless showing wins) |
| Krisp meeting notes | `key_points`, `action_items`, decisions from `detailed_summary` | Speaker intros, small talk |
| Granola notes | Decisions, structured action items, named blockers | Restated agenda, pleasantries |
| Linear issues | Status, assignee, milestone date, priority | Issue body detail, comment history |
| Linear projects | Completion %, milestone names + dates, member list | Internal tags, sub-issue detail |

**If input is incomplete**, ask:
- "What's the target date for [X]?"
- "Who owns [X]?"
- "Is [X] blocked or just in progress?"

Don't invent. Ask or flag as TBD.

## Step 3: Apply Core Principles

**Owners + Asks**: Every action item names a person and what they should do.
```
❌ "We need to fix the bug"
✅ "@Sarah to fix auth bug by EOD Friday"
```

**Request Acknowledgment**: Explicitly ask people to confirm — dramatically increases replies.
```
If your name is above, please acknowledge.
```

**Visual Status**: Use emoji for scannability: 🟢🟡🔴 for health, ✅🔨⏳ for progress, 🚀🎉 for launches

**Low Friction**: Frame asks so people can reply fast.
```
❌ "Please provide a comprehensive status update"
✅ "Quick pulse check—are you blocked?"
```

**Concrete Dates**: "EOD Friday" not "soon"; "12/15" not "mid-December"

**End with Invitation**: "Let me know if I missed anything" gives permission to respond.

---

## Templates

### OKR Update (Board-Ready)
For board/leadership. Cross-initiative visibility without project-level detail.

**Rules:**
- Group by initiative, not OKR number
- "Not in OKRs" section first
- State before action; no owners
- Acknowledge slips directly — no spin
- 2-5 bullets per section

**Bullet formula:** `[Project]: [Current state]; [Next milestone or blocker]`

```
== Work currently not represented in OKRs ==
- [Project]: [state]; [next step or dependency]

== [Initiative 1] ==
- [State]; Next milestone: [date]
- [State]; will not hit [date]; [recovery plan]

== [Initiative 2] ==
- [State]; [milestone or blocker]
- No external blockers (if true)
```

| Include | Exclude |
|---------|---------|
| Milestone dates, slips, blockers, state changes | Owner names, task detail, metrics deep-dives |

---

### Project Status Update (Exec-Ready)
For execs/stakeholders. Cross-functional project tracking.

**Rules:**
- 3 bullet max per section
- One line per workstream
- Blockers only if material
- 30-second read time max
- Details go in thread, not main message

```
**Project Update** - [Project Name] - [Date]

**Status by Workstream**
• [Workstream]: [emoji] [One-line] - @owner
• [Workstream]: [emoji] [One-line] - @owner
• [Workstream]: [emoji] [One-line] - @owner

**Blockers** (if any)
• [Blocker]: [Business impact] - @owner resolving

**Next Milestone**: [What] by [Date]

(details in thread)
```

Reply to yourself with: links, expanded blocker context, metrics, anything that didn't make the cut.

---

### Weekly/Sprint Update
For team updates. What's done → What's next → Blockers.

```
[Emoji] [Team/Project] Weekly Update - [Date]

**Released** 🚀
• [Item] - @owner
• [Item] - @owner

**In Progress** 🔨
• [Item] - @owner - [target date]
• [Item] - @owner - [target date]

**Blockers** ⚠️
• [Blocker]: [Impact] - @owner investigating

cc @stakeholder1 @stakeholder2
```

---

### Async Standup
For daily team rhythm. Quick, structured, no fluff.

```
**[Name]** - [Date]

**Yesterday:** [What got done]
**Today:** [What's planned]
**Blockers:** [None / specific blocker]
```

Or combined team format:
```
🧵 **Standup - [Date]**

@person1: [one-liner on focus today]
@person2: [one-liner on focus today]
@person3: 🔴 blocked on [X]

Reply in thread with details or blockers.
```

---

### Launch Announcement
For shipping news. Celebrate → Status → Next steps.

```
[Project] Launch Update: We are live! 🎉

1. [Key metric/milestone achieved]
2. [What's working]
3. [Known issues being addressed]

**Immediate next steps:**
1. ([Day]) [Task] @owner
2. ([Day]) [Task] @owner

**Follow-ups after [milestone]:**
1. [Task] @owner
2. [Task] @owner

Let me know if I missed anything!
```

---

### Queue Pulse Check
For ops/support. Priority tiers with case references.

```
Hi team — quick queue pulse check before EOD.

🚨 **Action needed today** ([N] cases):
Response needed—doesn't have to be a full solve, just a status update.
• @person1 [case#]
• @person2 [case#], [case#]

🧹 **Quick wins / closures:**
• @person3 [case#] ✅
• @person4 [case#]

Let us know if you're blocked!
```

---

### Escalation Thread
For issues needing decisions. Problem → Impact → Options → Ask.

```
Hi Team,

[Brief context on the issue]

**The Problem:**
• [Specific issue with data/examples]
• [Business impact]

**What We've Tried:**
1. [Option] - [Result]
2. [Option] - [Result]

**Options Forward:**
1. [Option A] - [Tradeoffs]
2. [Option B] - [Tradeoffs]

Recommend [X] because [reason]. @decisionmaker can we align?

cc @stakeholder1 @stakeholder2
```

---

### Handoff Update
For OOO or ownership transitions. State → Outstanding → Owners → Escalation.

```
**Handoff: [Project/Area]** - [Name] OOO [dates]

**Current State:**
• [Where things stand]

**Outstanding Items:**
• [Item] - @newowner - due [date]
• [Item] - @newowner - due [date]

**While I'm Out:**
• Questions → @backup
• Urgent escalation → @manager

Back [date]. Will check Slack [frequency, if any].
```