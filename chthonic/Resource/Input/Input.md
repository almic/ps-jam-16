Input is managed by G.U.I.D.E., a system like Unreal Engine's Enhanced Input.

The concept is simple, you have actions that can also convey values, and those
actions can be triggered by inputs under certain contexts.

This allows the code to focus purely on the action without regard for how that
action was triggered. It also allows the code to manage input contexts, so
certain inputs can be mapped to multiple actions, but only the active context
will produce actions.
