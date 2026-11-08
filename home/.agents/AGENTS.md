# Code Quality Standards

- Use tools to gather information rather than relying on assumptions
- Examine existing code before making changes
- Follow existing code style and patterns in the project
- Name meaningfully. Follow word pattern generic to specific. Stop when name fully identifies what the thing is across codebase.
list -> unmergedPRs
data -> sessionCookieHeader
name -> repoOwnerLogin
- Make error states unrepresentable. If int can't be negative, make it unsigned.

# Code Comments Philosophy

Comments are only added when the code's purpose or logic is not immediately
evident. Never write comments that merely restate what the code does (e.g.
`// increment counter` above `counter++`). Comments should explain **why**
something is done a certain way, document non-obvious edge cases, or clarify
complex algorithms that cannot be simplified further.

Keep comments short and to the point:

- Prefer a single concise line over a multi-line block
- Cut filler words, restated context, and obvious explanations
- Write terse notes, not prose — assume an experienced reader
- If a comment needs a paragraph, the code probably needs refactoring instead
- For comments expressing doubt like `Q: <question>`, write your answer in the report.

# Code reuse

- Default to inline. Flow reads top to bottom in one function.
- A new function needs one of: potential for many call sites, error return type, specific an external entry point (API, CLI, event handler), a protocol/interface requirement, or direct test coverage. Otherwise inline it.
- Never extract just to shorten a function. Length is fine; a hidden jump is not.
- Duplicating three lines once beats an abstraction guessed wrong.
